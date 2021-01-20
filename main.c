#include <stdio.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <sys/mman.h>
#include <elf.h>
#include <sys/mman.h>


#define PAGE_SIZE 4096

int main(void)
{
	char		buffer[50] = "/proc/";

	for (int i = 0; i < 3; i++)
		buffer[6 +  i] = 'c';
	return (0);
}
