/*
 * Copyright (C) 2016 Sven Brauch <mail@svenbrauch.de>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; see the file COPYING.LIB.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

/**
This library is intended to be used together with the AppImage distribution mechanism.
Place the library somewhere in your AppImage and point LD_PRELOAD to it
before launching your application.

Whenever your application invokes a child process through execv() or execve(),
this wrapper will intercept the call and see if the child process lies
outside of the bundled appdir. If it does, the wrapper will attempt to undo
any changes done to environment variables before launching the process,
since you probably did not intend to launch it with e.g. the LD_LIBRARY_PATH
you previously set for your application.

To perform this operation, you have to set the following environment variables:
  $APPDIR -- path of the AppDir you are launching your application from. If this
             is not present, the wrapper will do nothing.

For each environment variable you want restored, where {VAR} is the name of the environment
variable (e.g. "PATH"):
  $APPIMAGE_ORIGINAL_{VAR} -- original value of the environment variable
  $APPIMAGE_STARTUP_{VAR} -- value of the variable when you were starting up
                             your application
*/

#define _GNU_SOURCE

#include <unistd.h>
#include <dlfcn.h>
#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include <stdlib.h>

typedef ssize_t (*execve_func_t)(const char* filename, char* const argv[], char* const envp[]);
static execve_func_t old_execve = NULL;

typedef ssize_t (*execvp_func_t)(const char* filename, char* const argv[]);
static execvp_func_t old_execvp = NULL;

// TODO implement me: execl, execlp, execle; but it's annoying work and nothing seems to use them
// typedef int (*execl_func_t)(const char *path, const char *arg);
// static execl_func_t old_execl = NULL;
//
// typedef int (*execlp_func_t)(const char *file, const char *arg);
// static execlp_func_t old_execlp = NULL;
//
// typedef int (*execle_func_t)(const char *path, const char *arg, char * const envp[]);
// static execle_func_t old_execle = NULL;

typedef int (*execv_func_t)(const char *path, char *const argv[]);
static execv_func_t old_execv = NULL;

typedef int (*execvpe_func_t)(const char *file, char *const argv[], char *const envp[]);
static execvpe_func_t old_execvpe = NULL;


char* APPIMAGE_ORIG_PREFIX = "APPIMAGE_ORIGINAL_";
char* APPIMAGE_STARTUP_PREFIX = "APPIMAGE_STARTUP_";
char* APPDIR = "APPDIR";

typedef struct {
    char** names;
    char** values;
} environment;

environment environment_alloc(size_t envc) {
    environment env;
    env.names = calloc(envc+1, sizeof(char*));
    env.values = calloc(envc+1, sizeof(char*));
    return env;
}

int arr_len(char* const x[]) {
    int len = 0;
    while ( x[len] != 0 ) {
        len++;
    }
    return len;
}

void stringlist_free(char* const envp[]) {
    if ( envp ) {
        for ( int i = 0; i < arr_len(envp); i++ ) {
            free(envp[i]);
        }
    }
}

char** stringlist_alloc(int size) {
    char** ret = calloc(size, sizeof(char*));
    return ret;
}

int environment_len(const environment env) {
    return arr_len(env.names);
}

void environment_free(environment env) {
    stringlist_free(env.names);
    stringlist_free(env.values);
}

void environment_append_item(environment env, char* name, int name_size, char* val, int val_size) {
    int count = environment_len(env);
    env.names[count] = calloc(name_size+1, sizeof(char));
    env.values[count] = calloc(val_size+1, sizeof(char));
    strncpy(env.names[count], name, name_size);
    strncpy(env.values[count], val, val_size);
}

int environment_find_name(environment env, char* name, int name_size) {
    int count = environment_len(env);
    for ( int i = 0; i < count; i++ ) {
        if ( !strncmp(env.names[i], name, name_size) ) {
            return i;
        }
    }
    return -1;
}

char** environment_to_stringlist(environment env) {
    int len = environment_len(env);
    char** ret = stringlist_alloc(len+1);
    for ( int i = 0; i < len; i++ ) {
        char* name = env.names[i];
        char* value = env.values[i];
        int result_len = strlen(name) + strlen(value) + 1;
        ret[i] = calloc(result_len+1, sizeof(char));
        strcat(ret[i], name);
        strcat(ret[i], "=");
        strcat(ret[i], value);
    }
    return ret;
}

char** adjusted_environment(const char* filename, char* const envp[]) {
    if ( !envp ) {
        return NULL;
    }

    int envc = arr_len(envp);

    char* appdir = NULL;

    environment orig = environment_alloc(envc);
    environment startup = environment_alloc(envc);
    int orig_prefix_len = strlen(APPIMAGE_ORIG_PREFIX);
    int startup_prefix_len = strlen(APPIMAGE_STARTUP_PREFIX);
    for ( int i = 0; i < envc; i++ ) {
        char* line = envp[i];
        int name_size = strchr(line, '=')-line;
        int val_size = strlen(line)-name_size-1;

        if ( !strncmp(line, APPIMAGE_ORIG_PREFIX, orig_prefix_len) ) {
            environment_append_item(orig, line+orig_prefix_len, name_size-orig_prefix_len,
                                          line+name_size+1, val_size);
        }
        if ( !strncmp(line, APPIMAGE_STARTUP_PREFIX, startup_prefix_len) ) {
            environment_append_item(startup, line+startup_prefix_len, name_size-startup_prefix_len,
                                             line+name_size+1, val_size);
        }
        if ( !strncmp(line, APPDIR, strlen(APPDIR)) ) {
            appdir = calloc(val_size+1, sizeof(char));
            strncpy(appdir, line+name_size+1, val_size);
        }
    }

    printf("appdir=\"%s\",  filename=\"%s\"\n",appdir,filename);
    environment new_env = environment_alloc(envc);
    char* appdir2 = "/tmp/.gimp-appimage";
    if ( appdir && strncmp(filename, appdir, strlen(appdir))  && strncmp(filename, appdir2, strlen(appdir2)) ) {
        // we have a value for $APPDIR and are leaving it -- perform replacement
        for ( int i = 0; i < envc; i++ ) {
            char* line = envp[i];
            if ( !strncmp(line, APPIMAGE_ORIG_PREFIX, strlen(APPIMAGE_ORIG_PREFIX)) ||
                 !strncmp(line, APPIMAGE_STARTUP_PREFIX, strlen(APPIMAGE_STARTUP_PREFIX)) )
            {
                // we are not interested in the backup vars here, don't copy them over
                continue;
            }

            int name_size = strchr(line, '=')-line;
            int val_size = strlen(line)-name_size-1;
            char* value = line+name_size+1;
            int value_len = strlen(value);

            int at_startup = environment_find_name(startup, line, name_size);
            int at_original = environment_find_name(orig, line, name_size);
            if ( at_startup == -1 || at_original == -1 ) {
                // no information, just keep it
                environment_append_item(new_env, line, name_size, value, value_len);
                continue;
            }

            char* at_start = startup.values[at_startup];
            int at_start_len = strlen(at_start);
            char* at_orig = orig.values[at_original];
            int at_orig_len = strlen(at_orig);

            // TODO HACK: do not copy over empty vars
            if ( strlen(at_orig) == 0 ) {
                continue;
            }

            if ( !strncmp(line+name_size+1, startup.values[at_startup], val_size) ) {
                // nothing changed since startup, restore old value
                environment_append_item(new_env, line, name_size, at_orig, at_orig_len);
                continue;
            }

            int chars_added = value_len > at_start_len;
            char* use_value = NULL;
            if ( chars_added > 0 ) {
                // something was added to the current value
                // take _original_ value of the env var and append/prepend the same thing
                use_value = calloc(strlen(at_orig) + chars_added + 1, sizeof(char));
                if ( !strncmp(value, at_start, at_start_len) ) {
                    // append case
                    strcat(use_value, value);
                    strcat(use_value, at_orig + strlen(value));
                }
                else if ( !strncmp(value+(value_len-at_start_len), at_start, at_start_len) ) {
                    // prepend case
                    strcat(use_value, at_orig + strlen(value));
                    strcat(use_value, value);
                }
                else {
                    // none of the above methods matched
                    // assume the value changed completely and simply keep what the application set
                    free(use_value);
                    use_value = NULL;
                }
            }
            if ( !use_value ) {
                environment_append_item(new_env, line, name_size, value, value_len);
            }
            else {
                environment_append_item(new_env, line, name_size, use_value, strlen(use_value));
                free(use_value);
            }
        }
    } else {
      printf("  not updating environment\n");
    }

    char** ret = NULL;
    if ( environment_len(new_env) > 0 ) {
        ret = environment_to_stringlist(new_env);
    }
    else {
        // nothing changed
        ret = stringlist_alloc(envc+1);
        for ( int i = 0; i < envc; i++ ) {
            int len = strlen(envp[i]);
            ret[i] = calloc(len+1, sizeof(char));
            strncpy(ret[i], envp[i], len);
        }
    }
    environment_free(orig);
    environment_free(startup);
    environment_free(new_env);
    free(appdir);
    return ret;
}

int execve(const char* filename, char* const argv[], char* const envp[]) {
  printf("Calling custom execve(%s) function\n", filename);
    char** new_envp = adjusted_environment(filename, envp);
    old_execve = dlsym(RTLD_NEXT, "execve");
    int ret = old_execve(filename, argv, new_envp);
    stringlist_free(new_envp);
    return ret;
}

int execv(const char* filename, char* const argv[]) {
  printf("Calling custom execv(%s) function\n", filename);
    char** new_envp = adjusted_environment(filename, environ);
    old_execve = dlsym(RTLD_NEXT, "execve");
    int ret = old_execve(filename, argv, new_envp);
    stringlist_free(new_envp);
    return ret;
}

int execvpe(const char* filename, char* const argv[], char* const envp[]) {
  printf("Calling custom execvpe(%s) function\n", filename);
    // TODO: might not be full path
    char** new_envp = adjusted_environment(filename, envp);
    old_execvpe = dlsym(RTLD_NEXT, "execvpe");
    int ret = old_execvpe(filename, argv, new_envp);
    stringlist_free(new_envp);
    return ret;
}

int execvp(const char* filename, char* const argv[]) {
  printf("Calling custom execvp(%s) function\n", filename);
    // TODO: might not be full path
    char** new_envp = adjusted_environment(filename, environ);
    old_execvpe = dlsym(RTLD_NEXT, "execvpe");
    int ret = old_execvpe(filename, argv, new_envp);
    stringlist_free(new_envp);
    return ret;
}
