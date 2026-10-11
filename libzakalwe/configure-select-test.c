#include <stdlib.h>
#include <sys/select.h>
#include <stddef.h>

int main(void)
{
	fd_set read_fd_set;
	FD_ZERO(&read_fd_set);
	FD_SET(0, &read_fd_set);
	return select(1, &read_fd_set, NULL, NULL, NULL);
}
