#define _GNU_SOURCE

#include <stdio.h>
#include <dirent.h>
#include <sys/types.h>
#include <fcntl.h>
#include <string.h>

int main(void)
{
	char	buffer[1024];

	int		fd = open("/tmp/test", O_RDONLY);
	int		fd2 = open("/tmp/test2", O_RDONLY);

	getdents64(fd, buffer, 1024);
	printf("%u\n", *(unsigned short *)(buffer + 16));
	printf("%d == %d\n", *(unsigned char *)(buffer + ((*(unsigned short *)(buffer + 16)) + 18)), DT_REG);
	printf("%s\n", buffer + ((*(unsigned short *)(buffer + 16)) + 19));
	emset(buffer, 0, 1024);
	getdents64(fd2, buffer, 1024);
	printf("%u\n", *(unsigned short *)(buffer + 16));
	printf("%s\n", buffer + 19);
	printf("%s\n", buffer + ((*(unsigned short *)(buffer + 16)) + 19));
	return (0);
}
