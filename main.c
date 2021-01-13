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

	struct stat f;
	int		fd;

	fd = open("/tmp/test/Hello", O_RDONLY);
	fstat(fd, &f);
	void	*addr = mmap(0, f.st_size, PROT_READ | PROT_WRITE, MAP_PRIVATE, fd, 0);

	Elf64_Ehdr *ehdr = (Elf64_Ehdr *)addr;
	Elf64_Phdr *phdr = (Elf64_Phdr *)(addr + ehdr->e_phoff);
	printf("%lu\n", phdr[0].p_offset);
	printf("%lu\n", phdr[1].p_offset);
	return (0);
}
