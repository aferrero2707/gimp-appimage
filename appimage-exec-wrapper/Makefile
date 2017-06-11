exec.so: exec.c
	gcc -std=c99 -o exec.so -shared exec.c -Wall -Wfatal-errors -fPIC -g -ldl

clean: exec.c exec.so
	rm exec.so
