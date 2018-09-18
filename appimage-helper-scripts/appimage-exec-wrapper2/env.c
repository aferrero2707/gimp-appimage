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

#define _GNU_SOURCE

#include "env.h"
#include "debug.h"

#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>

static char** env_allocate(size_t size) {
    return calloc(size + 1, sizeof(char*));
}

void env_free(char* const *env) {
    size_t len = 0;
    while (env[len] != 0) {
        free(env[len]);
        len++;
    }
    free((char**)env);
}

static size_t get_number_of_variables(FILE *file, char **buffer, size_t *len) {
    size_t number = 0;

    if (getline(buffer, len, file) < 0)
        return -1;

    char *ptr = *buffer;
    while (ptr < *buffer + *len) {
        size_t var_len = strlen(ptr);
        ptr += var_len + 1;
        if (var_len == 0)
            break;
        number++;
    }

    return number != 0 ? (ssize_t)number : -1;
}

static char* const* env_from_buffer(FILE *file) {
    char *buffer = NULL;
    size_t len = 0;
    size_t num_vars = get_number_of_variables(file, &buffer, &len);
    char** env = env_allocate(num_vars);

    size_t n = 0;
    char *ptr = buffer;
    while (ptr < buffer + len && n < num_vars) {
        size_t var_len = strlen(ptr);
        if (var_len == 0)
            break;

        env[n] = calloc(sizeof(char*), var_len + 1);
        strncpy(env[n], ptr, var_len + 1);
        DEBUG("\tenv var copied: %s\n", env[n]);
        /*printf("\tenv var copied: %s\n", env[n]);*/
        ptr += var_len + 1;
        n++;
    }
    free(buffer);
    DEBUG("\tenv: %p\n", (void*)env);

    return env;
}

static char* const* read_env_from_process(pid_t pid) {
    char buffer[256] = {0};

    const char *envfile = getenv("AIPENV");
    if (!envfile)
        return NULL;
    DEBUG("AIPENV = %s\n", envfile);


    snprintf(buffer, sizeof(buffer), "%s", envfile);
    /*snprintf(buffer, sizeof(buffer), "/proc/%d/environ", pid);*/
    DEBUG("Reading env from parent process: %s\n", buffer);
    FILE *env_file = fopen(buffer, "r");
    if (!env_file) {
        DEBUG("Error reading file: %s (%s)\n", buffer, strerror(errno));
        return NULL;
    }

    char* const* env = env_from_buffer(env_file);
    fclose(env_file);

    return env;
}

char* const* read_parent_env() {
    pid_t ppid = getppid();
    return read_env_from_process(ppid);
}

#ifdef ENV_TEST
int main() {
    putenv("APPIMAGE_CHECKRT_DEBUG=1");
    DEBUG("ENV TEST\n");
    char **env = NULL;
    read_parent_env(&env);

    return 0;
}
#endif

