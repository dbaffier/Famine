#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdint.h>
#include <assert.h>

// void RC4(char *key, unsigned char *plaintext, uint32_t size);

#define FNV_PRIME_64 1099511628211
#define FNV_OFFSET_64 0xcbf29ce484222325

uint64_t FNV32(const char *s)
{
    uint64_t hash = FNV_OFFSET_64;
    uint32_t j = 21;
    uint32_t i = 0;
    while (j > 0)
    {
        hash = hash ^ (s[i]); // xor next byte into the bottom of the hash
        hash = hash * FNV_PRIME_64; // Multiply by prime number found to work well
        j--;
        i++;
    }
    return hash;
} 

// This is technically the FNVa hash, which reverses the xor and
// multiplication, but is believed to give better mixing for short strings
// (ie 4 bytes).
 
int main(void)
{
    char *teststring1 = "\x50\x51\x52\x48\x89\xe1\x48\x89\xec\x5d\x58\x48\x8d\x15\x4d\x00\x00\x00\x52\x52\xc3";

uint64_t ulong_value = FNV32(teststring1);
printf("%llx\n", ulong_value);
printf("%llu\n", ulong_value);
const int n = snprintf(NULL, 0, "%llu", ulong_value);
assert(n > 0);
char buf[n+1];
int c = snprintf(buf, n+1, "%llu", ulong_value);
assert(buf[n] == '\0');
assert(c == n);
printf("Buf : [%s]\n", buf);
}
