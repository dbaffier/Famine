#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>


char    *uint_to_string(uint64_t input)
{
    char *res = malloc(50);
    int     i;
    i = 0;

    while (input > 9)
    {
        char c = input % 16;
        if (c < 10)
            c += '0';
        else
            c += 'A' - 10;
        input /= 16;
        res[i] = c;
	printf("%c-", c);
        i++;
    }
    res[i] = 0;
    printf("\n%s\n", res);
    // printf("%s\n", strrev(res));
}

int main(void)
{
 //   uint64_t number = 0xa236057d1ffcee9;
    uint64_t number = 0xda9123f5dcc95c35;
    uint_to_string(number);
    return (0);
}
