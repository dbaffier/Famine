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
	int ret = ptrace(0, 1, 0, 0);
	printf("%d\n", ret);
	return (0);
}
