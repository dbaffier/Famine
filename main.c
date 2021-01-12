#include <stdio.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <sys/mman.h>

int main(void)
{
	struct stat c;

	int	fd = open("/tmp/test2/TEST_2", O_RDONLY);
	fstat(fd, &c);
	void	*addr = mmap(NULL, c.st_size, PROT_READ | PROT_WRITE, MAP_PRIVATE, fd, 0);

	return (0);
}
