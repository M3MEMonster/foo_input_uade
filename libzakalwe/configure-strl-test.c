#include <string.h>

void strl_test_function(void)
{
	char src[4];
	char dst[4];
	strlcat(dst, src, 1);
	strlcpy(dst, src, 1);
}

int main(void)
{
	strl_test_function();
	return 0;
}
