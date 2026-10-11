#include <zakalwe/file.h>
#include <zakalwe/string.h>

#include <errno.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>

static void test_z_list_dir(void)
{
	struct str_array *names = z_list_dir("test-dir");
	z_assert(str_array_len(names) == 1);
	z_assert(strcmp(str_array_get(names, 0), "a") == 0);
	str_array_free_all(names);
}

static void test_z_mkdtemp(void)
{
	char path[PATH_MAX];

	char *tmp = z_mkdtemp(NULL);
	z_assert(tmp != NULL);
	char *tmp2 = z_mkdtemp(tmp);
	z_assert(tmp2 != NULL);

	z_snprintf_or_die(path, PATH_MAX, "%s/placeholder", tmp2);
	fclose(fopen(path, "w"));

	z_assert(z_rmdir_recursively(tmp));

	free(tmp);
	free(tmp2);
}

int main(void)
{
	test_z_list_dir();
	test_z_mkdtemp();
}
