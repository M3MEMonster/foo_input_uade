#include <zakalwe/base.h>
#include <zakalwe/map.h>

#include <string.h>

struct foo {
	int x;
};

static int intcmp(const int x, const int y)
{
	if (x < y)
		return -1;
	if (y < x)
		return 1;
	return 0;
}

static int binary_cmp(const void *x, const void *y)
{
	return memcmp(x, y, 16);
}

Z_MAP_PROTOTYPE(int_map, char *, int, strcmp)
Z_MAP_PROTOTYPE(foo_map, int, struct foo, intcmp)
Z_MAP_PROTOTYPE(foo_ptr_map, int, struct foo *, intcmp)
Z_MAP_PROTOTYPE(binary_key_map, void *, int, binary_cmp)
Z_SCALAR_MAP_PROTOTYPE(int_map_2, struct foo *, int)


static void test_map_0(void)
{
	struct int_map *m;
	int i;
	m = int_map_create();
	z_assert(m != NULL);
	z_assert(int_map_len(m) == 0);
	z_assert(int_map_has(m, "key") == 0);
	z_assert(int_map_get_default(m, "key", -1) == -1);
	i = 123;
	z_assert(int_map_get_2(&i, m, "key") == 0);
	z_assert(i == 123);

	z_assert(int_map_set(m, "key", 2) == 1);
	z_assert(int_map_has(m, "key"));
	z_assert(int_map_len(m) == 1);
	z_assert(int_map_get(m, "key") == 2);
	z_assert(int_map_get_default(m, "key", -1) == 2);
	i = 123;
	z_assert(int_map_get_2(&i, m, "key") == 1);
	z_assert(i == 2);
	z_assert(int_map_get_default(m, "key1", -1) == -1);
	i = 123;
	z_assert(int_map_get_2(&i, m, "key1") == 0);
	z_assert(i == 123);

	/* Replace a key-value. */
	z_assert(int_map_has(m, "key"));
	z_assert(int_map_set(m, "key", 3) == 1);
	z_assert(int_map_get(m, "key") == 3);
	z_assert(int_map_get_default(m, "key", -1) == 3);
	i = 123;
	z_assert(int_map_get_2(&i, m, "key") == 1);
	z_assert(i == 3);

	int_map_free(m);
}

static void test_map_alloc(void)
{
	struct int_map *m = int_map_create();
	int x;
	z_assert(m != NULL);
	z_assert(int_map_set(m, "key0", 0) == 1);
	z_assert(int_map_set(m, "key1", 1) == 1);
	z_assert(int_map_pop(m, "key1") == 1);
	/* Should re-use the node from free_nodes array, internally. */
	z_assert(int_map_set(m, "key1", 1) == 1);

	x = 0;
	z_assert(int_map_pop_2(&x, m, "key1") == 1);
	z_assert(x == 1);

	z_assert(int_map_pop_2(&x, m, "key1") == 0);
	int_map_free(m);
}

static void test_map_iter(void)
{
	struct int_map *m;
	struct int_map_iter iter;
	int i;

	m = int_map_create();
	z_assert(m != NULL);
	z_assert(int_map_set(m, "key0", 2) == 1);
	z_assert(int_map_set(m, "key1", 3) == 1);

	i = 0;
	for (int_map_begin(&iter, m); int_map_end(&iter); int_map_next(&iter)) {
		if (i == 0) {
			z_assert(strcmp(iter.key, "key0") == 0);
			z_assert(iter.value == 2);
		} else if (i == 1) {
			z_assert(strcmp(iter.key, "key1") == 0);
			z_assert(iter.value == 3);
		} else {
			z_assert(0);
		}
		i++;
	}

	i = 0;
	for (int_map_begin_last(&iter, m);
	     int_map_end(&iter);
	     int_map_next(&iter)) {
		if (i == 0) {
			z_assert(strcmp(iter.key, "key1") == 0);
			z_assert(iter.value == 3);
		} else if (i == 1) {
			z_assert(strcmp(iter.key, "key0") == 0);
			z_assert(iter.value == 2);
		} else {
			z_assert(0);
		}
		i++;
	}

	i = 0;
	z_map_for_each(int_map, m, &iter) {
		if (i == 0) {
			z_assert(strcmp(iter.key, "key0") == 0);
			z_assert(iter.value == 2);
		} else if (i == 1) {
			z_assert(strcmp(iter.key, "key1") == 0);
			z_assert(iter.value == 3);
		} else {
			z_assert(0);
		}
		i++;
	}

	i = 0;
	z_map_for_each_reverse(int_map, m, &iter) {
		if (i == 0) {
			z_assert(strcmp(iter.key, "key1") == 0);
			z_assert(iter.value == 3);
		} else if (i == 1) {
			z_assert(strcmp(iter.key, "key0") == 0);
			z_assert(iter.value == 2);
		} else {
			z_assert(0);
		}
		i++;
	}

	int_map_free(m);
}

static void test_map_iter_modify(void)
{
	struct int_map m = Z_EMPTY_MAP;
	struct int_map_iter iter;
	char *key0 = strdup("key0");
	char *key1 = strdup("key1");
	z_assert(key0 != NULL);
	z_assert(key1 != NULL);

	z_assert(int_map_set(&m, key0, 2) == 1);
	z_assert(int_map_set(&m, key1, 3) == 1);

	for (int_map_begin(&iter, &m);
	     int_map_end(&iter);
	     int_map_next(&iter)) {
		if (iter.key == key0) {
			z_assert(iter.value == 2);
			int_map_pop_current(&m, &iter);
		}
	}
	int_map_deinit(&m);
	free(key0);
	free(key1);
}

static void test_map_set(void)
{
	struct int_map *m;
	int ret;
	int did_replace;
	int replaced_value;
	m = int_map_create();
	z_assert(m != NULL);
	z_assert(int_map_set(m, "key0", 2) == 1);
	z_assert(int_map_get(m, "key0") == 2);
	replaced_value = 0;
	did_replace = 0;
	ret = int_map_set_2(m, "key0", 3, &did_replace, &replaced_value);
	z_assert(ret == 1);
	z_assert(did_replace);
	z_assert(replaced_value == 2);

	replaced_value = 0;
	ret = int_map_set_2(m, "key1", 4, &did_replace, &replaced_value);
	z_assert(ret);
	z_assert(!did_replace);
	z_assert(replaced_value == 0);

	int_map_free(m);
}

static void test_foo_map(void)
{
	struct foo_map *m;
	struct foo x;
	m = foo_map_create();
	z_assert(m != NULL);
	z_assert(foo_map_len(m) == 0);
	z_assert(foo_map_has(m, 0) == 0);
	z_assert(foo_map_set(m, 0, (struct foo) {.x = 2}) == 1);
	z_assert(foo_map_has(m, 0));
	x = foo_map_get(m, 0);
	z_assert(x.x == 2);
	foo_map_free(m);
}

static void test_foo_ptr_map(void)
{
	struct foo_ptr_map *m = foo_ptr_map_create();
	struct foo *x = z_calloc_target(x);
	struct foo *y;
	z_assert(m != NULL);
	z_assert(x != NULL);
	x->x = 2;
	z_assert(foo_ptr_map_len(m) == 0);
	z_assert(foo_ptr_map_has(m, 0) == 0);
	z_assert(foo_ptr_map_set(m, 0, x) == 1);
	z_assert(foo_ptr_map_has(m, 0));
	y = foo_ptr_map_get(m, 0);
	z_assert(y->x == 2);
	foo_ptr_map_free(m);
	free(x);
}

static void test_scalar_map(void)
{
	struct int_map_2 m;
	struct foo *x = (struct foo *) 1;
	struct foo *y = (struct foo *) 2;
	int_map_2_init(&m);
	z_assert(int_map_2_set(&m, x, 1));
	z_assert(int_map_2_set(&m, y, 2));
	z_assert(int_map_2_get(&m, x) == 1);
	z_assert(int_map_2_get(&m, y) == 2);
	int_map_2_deinit(&m);
}

static void test_empty_map(void)
{
	struct int_map m = Z_EMPTY_MAP;
	int i;
	z_assert(int_map_len(&m) == 0);
	z_assert(int_map_has(&m, "key") == 0);
	z_assert(int_map_get_default(&m, "key", -1) == -1);
	i = 123;
	z_assert(int_map_get_2(&i, &m, "key") == 0);
	z_assert(i == 123);

	z_assert(int_map_set(&m, "key", 2) == 1);
	z_assert(int_map_has(&m, "key"));
	z_assert(int_map_len(&m) == 1);
	z_assert(int_map_get(&m, "key") == 2);
	z_assert(int_map_get_default(&m, "key", -1) == 2);
	i = 123;
	z_assert(int_map_get_2(&i, &m, "key") == 1);
	z_assert(i == 2);
	z_assert(int_map_get_default(&m, "key1", -1) == -1);
	i = 123;
	z_assert(int_map_get_2(&i, &m, "key1") == 0);
	z_assert(i == 123);

	/* Replace a key-value. */
	z_assert(int_map_has(&m, "key"));
	z_assert(int_map_set(&m, "key", 3) == 1);
	z_assert(int_map_get(&m, "key") == 3);
	z_assert(int_map_get_default(&m, "key", -1) == 3);
	i = 123;
	z_assert(int_map_get_2(&i, &m, "key") == 1);
	z_assert(i == 3);

	int_map_deinit(&m);
}

static void test_binary_key_map(void)
{
	struct binary_key_map *m = binary_key_map_create();
	void *key0 = z_calloc_or_die(1, 16);
	void *key1 = z_calloc_or_die(1, 16);
	z_assert(m != NULL);
	z_assert(key0 != NULL);
	z_assert(binary_key_map_len(m) == 0);
	z_assert(binary_key_map_has(m, key0) == 0);
	z_assert(binary_key_map_set(m, key0, 3) == 1);
	z_assert(binary_key_map_has(m, key0));

	z_assert(binary_key_map_has(m, key1));
	memset(key1, -1, 16);
	z_assert(binary_key_map_has(m, key1) == 0);;

	z_assert(binary_key_map_get(m, key0) == 3);
	binary_key_map_free(m);
	free(key0);
	free(key1);
}

static void free_str(char *s)
{
	free(s);
}

static void test_cleanup_keys(void)
{
	struct int_map *m;
	char *key0 = strdup("key0");
	char *key0dupe = strdup("key0");
	z_assert(key0 != NULL);
	z_assert(key0dupe != NULL);

	m = int_map_create();
	z_assert(m != NULL);

	int_map_cleanup_keys(m, free_str);

	/*
	 * Note: callee takes ownership of key0 on *_set() call.
	 * You may not use it after this. */
	z_assert(int_map_set(m, key0, 3) == 1);
	key0 = NULL;
	z_assert(int_map_set(m, key0dupe, 3) == 1);

	/*
	 * Note: we may not use key0, but we must use "key0" because the map
	 * owns key0 at this point.
	 */
	z_assert(int_map_get(m, "key0") == 3);
	z_assert(int_map_pop(m, "key0") == 3);

	int_map_free(m);
}

int main(void)
{
	test_map_0();
	test_map_alloc();
	test_map_set();
	test_map_iter();
	test_map_iter_modify();
	test_foo_map();
	test_foo_ptr_map();
	test_scalar_map();
	test_empty_map();
	test_binary_key_map();
	test_cleanup_keys();
	return 0;
}
