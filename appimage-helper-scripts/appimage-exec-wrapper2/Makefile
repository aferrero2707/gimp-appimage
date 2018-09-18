exec.so: exec.c env.c
	gcc -std=c99 -o exec.so -shared exec.c env.c -Wall -Wfatal-errors -fPIC -g -ldl

clean: exec.c exec.so
	rm exec.so
