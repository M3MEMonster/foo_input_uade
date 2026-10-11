#include <zakalwe/base.h>
#include <zakalwe/next/hash64.h>
#include <zakalwe/hash-utils.h>
#include <zakalwe/mem.h>
#include <stdlib.h>
#include <string.h>

struct item {
	char *s;
};

static int item_compare(const void *a, const void *b, const void *opaque)
{
	const struct item *item_a = a;
	const struct item *item_b = b;
	(void) opaque;
	return strcmp(item_a->s, item_b->s);
}

static void *item_create(const char *s)
{
	struct item *item = calloc(1, sizeof item[0]);
	z_assert(item != NULL);
	item->s = strdup(s);
	z_assert(item->s != NULL);
	return item;
}

static void item_free(struct item *item)
{
	z_free_and_null(item->s);
	free(item);
}

static void test_hash64(void)
{
	struct hash64 *ht = hash64_create(2);
	struct item *item0 = item_create("item0");
	struct item *item1 = item_create("item1");
	struct item *item0_dup = item_create("item0");
	z_assert(ht != NULL);

	z_assert(hash64_insert(ht, 0, item0, NULL, item_compare));
	z_assert_eq(hash64_len(ht), 1);
	z_assert_false(hash64_insert(ht, 0, item0, NULL, item_compare));
	z_assert_eq(hash64_len(ht), 1);

	z_assert(hash64_insert(ht, 0, item1, NULL, item_compare));
	z_assert_eq(hash64_len(ht), 2);
	z_assert_false(hash64_insert(ht, 0, item1, NULL, item_compare));
	z_assert_eq(hash64_len(ht), 2);

	z_assert(hash64_insert(ht, 1, item1, NULL, item_compare));
	z_assert_eq(hash64_len(ht), 3);
	z_assert_false(hash64_insert(ht, 1, item1, NULL, item_compare));
	z_assert_eq(hash64_len(ht), 3);

	z_assert(hash64_lookup(ht, 0, item0_dup, NULL, item_compare) ==
		    item0);
	z_assert(hash64_lookup(ht, 0, item0, NULL, item_compare) ==
		    item0);
	z_assert(hash64_lookup(ht, 1, item0_dup, NULL, item_compare) ==
		    NULL);

	z_assert(hash64_remove(ht, 0, item1, NULL, item_compare) ==
		    item1);
	z_assert_eq(hash64_len(ht), 2);

	z_assert(hash64_remove(ht, 0, item0_dup, NULL, item_compare) ==
		    item0);
	z_assert_eq(hash64_len(ht), 1);

	z_assert(hash64_remove(ht, 1, item1, NULL, item_compare) ==
		    item1);
	z_assert_eq(hash64_len(ht), 0);

	hash64_free(ht);
	item_free(item0);
	item_free(item1);
	item_free(item0_dup);
}

int main(void)
{
	test_hash64();
	return 0;
}
