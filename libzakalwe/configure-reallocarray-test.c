#include <stdlib.h>

int main(void)
{
	void *x = reallocarray(NULL, 1, 1);
	int ret = (x == NULL);
	free(x);
	return ret;
}
