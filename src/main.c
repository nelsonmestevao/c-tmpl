#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/**
 * Importante
 * @param argc quantos argumentos
 * */
int main(int argc, char **argv) {
    if (argc < 1) {
        printf("Unexpected number of arguments\n");
        return -1;
    }

    printf("You entered in reverse order:\n\n");

    while (argc-- != 0) {
        printf("* %s\n", argv[argc]);
    }

    return 0;
}
