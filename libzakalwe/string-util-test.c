#include <zakalwe/string.h>

#include <string.h>

static void test_strl(void)
{
	char src[4];
	char longer_src[6];
	char dst[4];
	int ret;

	strcpy(src, "a");
	strcpy(dst, "b");
	z_assert(strlcpy(dst, src, sizeof dst) == 1);
	ret = strcmp(dst, "a");
	z_assert(ret == 0);

	strcpy(src, "a");
	strcpy(dst, "b");
	z_assert(strlcat(dst, src, sizeof dst) == 2);
	ret = strcmp(dst, "ba");
	z_assert(ret == 0);

	strcpy(src, "abc");
	strcpy(dst, "def");
	z_assert(strlcat(dst, src, sizeof dst) == 6);
	ret = strcmp(dst, "def");
	z_assert(ret == 0);

	strcpy(src, "abc");
	strcpy(dst, "de");
	z_assert(strlcat(dst, src, sizeof dst) == 5);
	ret = strcmp(dst, "dea");
	z_assert(ret == 0);

	strcpy(longer_src, "abcde");
	strcpy(dst, "");
	z_assert(strlcat(dst, longer_src, sizeof dst) == 5);
	ret = strcmp(dst, "abc");
	z_assert(ret == 0);

	z_snprintf_or_die(dst, sizeof(dst), "a/%s", "b");
	z_assert(strcmp(dst, "a/b") == 0);

	z_snprintf_or_die(dst, 0, "b/%s", "c");
	z_assert(strcmp(dst, "a/b") == 0);
}

static void test_z_string(void)
{
	struct z_string *zs = z_string_create();
	z_assert(zs != NULL);
	z_assert(z_string_cat_c_str(zs, "a"));
	z_assert(strcmp(zs->s, "a") == 0);
	z_assert(zs->len == 1);
	z_assert(z_string_cat_c_str(zs, "a"));
	z_assert(strcmp(zs->s, "aa") == 0);
	z_assert(zs->len == 2);
	z_string_free(zs);
}

int main(void)
{
	test_strl();
	test_z_string();
	return 0;
}
