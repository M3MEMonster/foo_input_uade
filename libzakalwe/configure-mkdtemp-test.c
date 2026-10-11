#include <stdlib.h>

int main(void)
{
	mkdtemp("/tmp/tmp.XXXXXX");
	return 0;
}
