/* Copyright (c) 2018 Pablo Marcos Oltra <pablo.marcos.oltra@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/*
 * This exec.so library is intended to restore the environment of the AppImage's
 * parent process. This is done to avoid library clashing of bundled libraries
 * with external processes. e.g when running the web browser
 *
 * The intended usage is as follows:
 *
 * 1. This library is injected to the dynamic loader through LD_PRELOAD
 *    automatically in AppRun **only** if `usr/optional/exec.so` exists:
 *    e.g `LD_PRELOAD=$APPDIR/usr/optional/exec.so My.AppImage`
 *
 * 2. This library will intercept calls to new processes and will detect whether
 *    those calls are for binaries within the AppImage bundle or external ones.
 *
 * 3. In case it's an internal process, it will not change anything.
 *    In case it's an external process, it will restore the environment of
 *    the AppImage parent by reading `/proc/[pid]/environ`.
 *    This is the conservative approach taken.
 */

#define _GNU_SOURCE

#include "env.h"
#include "debug.h"

#include <stdlib.h>
#include <unistd.h>
#include <dlfcn.h>
#include <string.h>
#include <errno.h>

typedef int (*execve_func_t)(const char *filename, char *const argv[], char *const envp[]);

#define MIN(X,Y) ((X) < (Y) ? (X) : (Y))

static const char* get_fullpath(const char *filename) {
    // Try to get the canonical path in case it's a relative path or symbolic
    // link. Otherwise, use which to get the fullpath of the binary
    char *fullpath = canonicalize_file_name(filename);
    DEBUG("filename %s, canonical path %s\n", filename, fullpath);
    if (fullpath)
        return fullpath;

    return filename;
}

static int is_external_process(const char *filename) {
    const char *appdirs = getenv("APPDIRS");
    if (!appdirs)
        return 0;
    DEBUG("APPDIRS = %s\n", appdirs);
    /*printf("is_external_process: filename = %s\n", filename);*/
    /*printf("is_external_process: APPDIRS = %s\n", appdirs);*/
    int pos = 0;
    int len = strlen(appdirs);
    /*printf("is_external_process: len = %d\n", len);*/
    while( pos < len) {
      int start = pos;
      /*printf("is_external_process: start = %d\n", start);*/
      while( pos < len) {
        //printf("is_external_process: appdirs[%d] = %c\n", pos, appdirs[pos]);
        if(appdirs[pos] == ':') {
          /*printf("is_external_process: path delimiter found\n");*/
          break;
        }
        pos += 1;
      }
      if(pos > start) {
        char* appdir = (char*)malloc(pos-start+1);
        strncpy(appdir, &(appdirs[start]), pos-start);
        appdir[pos-start] = '\0';
        /*printf("is_external_process: appdir = %s\n", appdir);*/
        int result = strncmp(filename, appdir, MIN(strlen(filename), strlen(appdir)));
        free(appdir);
        if( result==0 ) {
          printf("is_external_process: bundled process found: %s\n", filename);
          return 0;
        }
      }
      pos += 1;
    }

    /*printf("is_external_process: external process found\n");*/
    return 1;
}

static int exec_common(execve_func_t function, const char *filename, char* const argv[], char* const envp[]) {
    const char *fullpath = get_fullpath(filename);
    DEBUG("filename %s, fullpath %s\n", filename, fullpath);
    char* const *env = envp;
    if (is_external_process(fullpath)) {
        DEBUG("External process detected. Restoring env vars from parent %d\n", getppid());
        env = read_parent_env();
        DEBUG("exec_common: env: %p\n", (void*)env);
        if (!env)
            env = envp;
        else
            DEBUG("Error restoring env vars from parent\n");
    }
    int ret = function(filename, argv, env);

    if (fullpath != filename)
        free((char*)fullpath);
    if (env != envp)
        env_free(env);

    return ret;
}

int execve(const char *filename, char *const argv[], char *const envp[]) {
    DEBUG("execve call hijacked: %s\n", filename);
    execve_func_t execve_orig = dlsym(RTLD_NEXT, "execve");
    if (!execve_orig)
        DEBUG("Error getting execve original symbol: %s\n", strerror(errno));

    return exec_common(execve_orig, filename, argv, envp);
}

int execv(const char *filename, char *const argv[]) {
    DEBUG("execv call hijacked: %s\n", filename);
    return execve(filename, argv, environ);
}

int execvpe(const char *filename, char *const argv[], char *const envp[]) {
    DEBUG("execvpe call hijacked: %s\n", filename);
    execve_func_t execve_orig = dlsym(RTLD_NEXT, "execvpe");
    if (!execve_orig)
        DEBUG("Error getting execvpe original symbol: %s\n", strerror(errno));

    return exec_common(execve_orig, filename, argv, envp);
}

int execvp(const char *filename, char *const argv[]) {
    DEBUG("execvp call hijacked: %s\n", filename);
    return execvpe(filename, argv, environ);
}

#ifdef EXEC_TEST
int main(int argc, char *argv[]) {
    putenv("APPIMAGE_CHECKRT_DEBUG=1");
    DEBUG("EXEC TEST\n");
    execv("./env_test", argv);

    return 0;
}
#endif
