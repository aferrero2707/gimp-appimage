#ifndef ENV_H
#define END_H

#include <unistd.h>

char* const* read_parent_env();
void env_free(char* const *env);

#endif
