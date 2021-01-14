#include <stdio.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <sys/mman.h>
#include <elf.h>


#define PAGE_SIZE 4096

int main(void)
{

	int	fd = open("/tmp/test/Hello", O_RDONLY);
	struct stat f;

	fstat(fd, &f);
	printf("%x\n", f.st_mode);
	int	fd2 = open("opop", O_CREAT | O_WRONLY | O_TRUNC, f.st_mode);

	return (0);
}
