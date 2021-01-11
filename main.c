#include <stdio.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

int main(void)
{
	struct stat c;

	int	fd = open("/tmp/test/first_one", O_RDONLY);
	fstat(fd, &c);
	printf("%zu\n", sizeof(struct stat));
	printf("%zu\n", sizeof(c.st_dev));
	printf("%zu\n", sizeof(c.st_ino));
	printf("%zu\n", sizeof(c.st_mode));
	printf("%zu\n", sizeof(c.st_nlink));
	printf("%zu\n", sizeof(c.st_uid));
	printf("%zu\n", sizeof(c.st_gid));
	printf("%zu\n", sizeof(c.st_rdev));
	printf("size => %zu\n", c.st_size);
	printf("%zu\n", sizeof(c.st_size));
	printf("%zu\n", sizeof(c.st_blksize));
	printf("%zu\n", sizeof(c.st_blocks));
	printf("%zu\n", sizeof(c.st_atime));
	printf("%zu\n", sizeof(c.st_mtime));
	printf("%zu\n", sizeof(c.st_ctime));
	printf("Hi\n");
	return (0);
}
