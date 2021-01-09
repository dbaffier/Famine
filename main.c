#include <stdio.h>
#include <fcntl.h>

int main(void)
{
	int		fd;


	fd = open("/tmp/test/ABC", O_RDONLY);

	write(1, "A", 1);
	return (0);
}
