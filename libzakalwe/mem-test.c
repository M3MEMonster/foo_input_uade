#include <zakalwe/base.h>
#include <zakalwe/mem.h>
#include <string.h>

static void clone_test(void)
{
	int array[3] = {3, 4, 5};
	int *new_array = z_clone_items(array, 3, sizeof array[0]);
	z_assert(memcmp(array, new_array, sizeof(array)) == 0);
	z_free_and_null(new_array);

	new_array = z_clone_items(array, 3, sizeof array[0]);
	z_assert(memcmp(array, new_array, sizeof(array)) == 0);
	z_free_and_null(new_array);
}

struct test {
	int x;
	int y;
};

static void malloc_target_test(void)
{
	struct test *t0 = z_malloc_target(t0);
	memset(t0, 0, sizeof(*t0));
	z_free_and_null(t0);

	t0 = z_calloc_target(t0);
	memset(t0, 0, sizeof(*t0));
	z_free_and_null(t0);
}

static void reallocarray_test(void)
{
	const size_t s = 2 * 1024 * 1024;
	char *p = reallocarray(NULL, 1024 * 1024, 2);
	memset(p, 0, s);
	z_free_and_null(p);
	z_assert(reallocarray(NULL, ((size_t) -1) / 2, 4) == NULL);
}

int main(void)
{
	malloc_target_test();
	clone_test();
	reallocarray_test();
	return 0;
}
