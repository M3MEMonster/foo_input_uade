#include <zakalwe/array.h>
#include <zakalwe/base.h>
#include <zakalwe/bitfield.h>

struct foo {
	int x;
};

static int compare_foo(const struct foo *a, const struct foo *b)
{
	if (a->x < b->x)
		return -1;
	if (b->x < a->x)
		return 1;
	return 0;
}

Z_ARRAY_PROTOTYPE(int_array, int)
Z_ARRAY_PROTOTYPE(int_ptr_array, int *)
Z_ARRAY_COMPARE_PROTOTYPE(foo_array, struct foo, compare_foo)
Z_PAIR_ARRAY_PROTOTYPE(pair_array, int, float)

static void test_array(void)
{
	struct int_array array;
	int i;
	array.num_items = -1;
	int_array_init(&array);
	z_assert(array.num_items == 0);
	int_array_append(&array, 0);
	int_array_append(&array, 1);
	int_array_append(&array, 2);
	int_array_append(&array, 3);
	for (i = 0; i < 4; i++) {
		z_assert(int_array_find(&array, i, 0) == (size_t) i);
		z_assert(int_array_get(&array, i) == i);
	}
	z_assert(int_array_find(&array, 0, 1) == (size_t) -1);
	/* start_pos >= array length. */
	z_assert(int_array_find(&array, 0, 4) == (size_t) -1);
	z_assert(int_array_find(&array, 0, 5) == (size_t) -1);
	/* value not in array. */
	z_assert(int_array_find(&array, 4, 0) == (size_t) -1);

	z_assert(int_array_pop(&array, 2) == 2);
	z_assert(int_array_len(&array) == 3);
	z_assert(int_array_get(&array, 0) == 0);
	z_assert(int_array_get(&array, 1) == 1);
	z_assert(int_array_get(&array, 2) == 3);

	z_assert(int_array_pop(&array, 2) == 3);
	z_assert(int_array_len(&array) == 2);

	/* Array contains [0, 1]. */
	int_array_append(&array, 2);
	z_assert(int_array_pop_fast(&array, 0) == 0);
	z_assert(int_array_len(&array) == 2);
	z_assert(int_array_get(&array, 0) == 2);
	z_assert(int_array_get(&array, 1) == 1);

	int_array_deinit(&array);
}

static void choice_test(const size_t upper_bound)
{
	struct int_array array = Z_EMPTY_ARRAY;
	size_t i;
	size_t count[8];
	struct z_random_state *rs = z_random_create_state();
	size_t lower_bound = (1000 / upper_bound) * 0.70;
	size_t higher_bound = (1000 / upper_bound) / 0.70;

	z_assert(upper_bound <= 8);
	memset(count, 0, sizeof count);

	for (i = 0; i < upper_bound; i++)
		z_assert(int_array_append(&array, (int) i));

	for (i = 0; i < 1000; i++) {
		size_t pos = upper_bound;
		const int x = int_array_choice(&pos, &array, rs);
		z_assert(pos < upper_bound);
		z_assert((size_t) x == pos);
		count[x]++;
	}

	/* Test by luck. */
	for (i = 0; i < upper_bound; i++) {
		if (!(count[i] >= lower_bound && count[i] < higher_bound)) {
			z_log_fatal("Error: i == %zu. count[i] == %zu. "
				  "upper_bound = %zu. "
				  "lower_bound = %zu. higher_bound = %zu.\n",
				  i, count[i], upper_bound, lower_bound,
				  higher_bound);
		}
	}

	int_array_deinit(&array);
	z_random_free_state(rs);
}

static void test_array_choice(void)
{
	size_t i;
	for (i = 1; i <= 8; i++)
		choice_test(i);
}

static void test_array_clone(void)
{
	struct int_array array = Z_EMPTY_ARRAY;
	struct int_array *new_array;
	size_t i;
	z_assert(int_array_append(&array, 0));
	z_assert(int_array_append(&array, 1));
	z_assert(int_array_append(&array, 2));
	new_array = int_array_clone(&array);
	z_assert_not_null(new_array);
	z_assert(int_array_len(new_array) == int_array_len(&array));
	for (i = 0; i < int_array_len(new_array); i++)
		z_assert(int_array_get(new_array, i) == (int) i);
	int_array_deinit(&array);
	int_array_free(new_array);

	/* Test fast cloning of an array with len == 0. */
	int_array_init(&array);
	new_array = int_array_clone(&array);
	z_assert_not_null(new_array);
	z_assert(new_array->items == NULL);
	int_array_deinit(&array);
	int_array_free(new_array);
}

static void test_array_count(void)
{
	struct int_array array = Z_EMPTY_ARRAY;
	z_assert(int_array_append(&array, 0));
	z_assert(int_array_append(&array, 1));
	z_assert(int_array_append(&array, 0));
	z_assert(int_array_count(&array, 0) == 2);
	z_assert(int_array_count(&array, 1) == 1);
	z_assert(int_array_count(&array, 2) == 0);
	int_array_deinit(&array);
}

static void test_array_create(void)
{
	struct int_array *array;
	array = int_array_create();
	z_assert(int_array_append(array, 0));
	z_assert(int_array_append(array, 1));
	int_array_free(array);
}

static void test_array_create2(void)
{
	struct int_array *array = int_array_create2(4);
	z_assert(array != NULL);
	z_assert(int_array_len(array) == 4);
	z_assert(int_array_get(array, 3) == 0);
	int_array_set(array, 3, 3);
	z_assert(int_array_get(array, 3) == 3);
	int_array_free(array);
}

static void test_array_extend(void)
{
	struct int_array src = Z_EMPTY_ARRAY;
	struct int_array dst = Z_EMPTY_ARRAY;
	size_t i;
	z_assert(int_array_append(&dst, 0));
	z_assert(int_array_append(&dst, 1));
	z_assert(int_array_append(&src, 2));
	z_assert(int_array_append(&src, 3));
	z_assert(int_array_extend(&dst, &src));
	for (i = 0; i < 4; i++)
		z_assert(int_array_get(&dst, i) == (int) i);
	z_assert(int_array_extend(&dst, &src));
	z_assert(int_array_get(&dst, 4) == 2);
	z_assert(int_array_get(&dst, 5) == 3);
	z_assert(int_array_extend(&dst, &src));
	z_assert(int_array_get(&dst, 6) == 2);
	z_assert(int_array_get(&dst, 7) == 3);
	int_array_deinit(&src);
	int_array_deinit(&dst);
}

static void test_array_free(void)
{
	int_array_free(NULL);
}

static int int_ptr_compare(const int **x, const int **y)
{
	if (*x < *y)
		return -1;
	else if (*y < *x)
		return 1;
	return 0;
}

static void test_array_insert(void)
{
	struct int_array array;
	/* pos == 0 && len > 0 */
	int_array_init(&array);
	z_assert(int_array_append(&array, 0));
	z_assert(int_array_append(&array, 1));
	z_assert(int_array_insert(&array, 0, 3));
	z_assert(int_array_get(&array, 0) == 3);
	z_assert(int_array_get(&array, 1) == 0);
	z_assert(int_array_get(&array, 2) == 1);
	int_array_deinit(&array);

	/* pos == 1 && len > pos */
	int_array_init(&array);
	z_assert(int_array_append(&array, 0));
	z_assert(int_array_append(&array, 1));
	z_assert(int_array_insert(&array, 1, 3));
	z_assert(int_array_get(&array, 0) == 0);
	z_assert(int_array_get(&array, 1) == 3);
	z_assert(int_array_get(&array, 2) == 1);
	int_array_deinit(&array);

	int_array_init(&array);
	/* pos == 0 && len == 0*/
	z_assert(int_array_insert(&array, 0, 3));
	z_assert(int_array_get(&array, 0) == 3);
	int_array_deinit(&array);

	int_array_init(&array);
	/* pos > len && len == 0 */
	z_assert(int_array_insert(&array, 1, 3));
	z_assert(int_array_get(&array, 0) == 3);
	/* pos > len && len == 1 */
	z_assert(int_array_insert(&array, 10, 4));
	z_assert(int_array_get(&array, 0) == 3);
	z_assert(int_array_get(&array, 1) == 4);
	int_array_deinit(&array);

	int_array_init(&array);
	/* pos == len && len == 1*/
	z_assert(int_array_append(&array, 0));
	z_assert(int_array_insert(&array, 1, 3));
	z_assert(int_array_get(&array, 0) == 0);
	z_assert(int_array_get(&array, 1) == 3);
	int_array_deinit(&array);
}

static void test_array_int_ptr(void)
{
	struct int_ptr_array array;
	int x = 0;
	int y = 0;
	int z = 0;
	int_ptr_array_init(&array);
	int_ptr_array_append(&array, &x);
	int_ptr_array_append(&array, &y);
	int_ptr_array_append(&array, &z);
	z_assert(int_ptr_array_get(&array, 0) == &x);
	z_assert(int_ptr_array_get(&array, 1) == &y);
	z_assert(int_ptr_array_get(&array, 2) == &z);
	int_ptr_array_truncate(&array, 0);
	int_ptr_array_append(&array, (int *) 3);
	int_ptr_array_append(&array, (int *) 2);
	int_ptr_array_append(&array, (int *) 1);
	int_ptr_array_sort(&array, int_ptr_compare);
	z_assert(int_ptr_array_get(&array, 0) == (int *) 1);
	z_assert(int_ptr_array_get(&array, 1) == (int *) 2);
	z_assert(int_ptr_array_get(&array, 2) == (int *) 3);
	int_ptr_array_deinit(&array);
}

static void test_array_iter(void)
{
	struct int_array array = Z_EMPTY_ARRAY;
	struct int_array_iter iter;
	int i;
	z_assert(int_array_append(&array, 1));
	z_assert(int_array_append(&array, 2));

	/* Test forward iteration. */
	i = 1;
	for (int_array_begin(&iter, &array);
	     int_array_end(&iter);
	     int_array_next(&iter)) {
		z_assert(iter.value == i);
		i++;
	}

	i = 1;
	z_array_for_each(int_array, &array, &iter) {
		z_assert(iter.value == i);
		i++;
	}

	/* Test reverse iteration. */
	i = 2;
	for (int_array_begin_last(&iter, &array);
	     int_array_end(&iter);
	     int_array_next(&iter)) {
		z_assert(iter.value == i);
		i--;
	}

	i = 2;
	z_array_for_each_reverse(int_array, &array, &iter) {
		z_assert(iter.value == i);
		i--;
	}

	int_array_deinit(&array);
}

static void test_array_pop_last(void)
{
	struct int_array array;
	int_array_init(&array);
	z_assert(int_array_append(&array, 0));
	z_assert(int_array_append(&array, 1));
	z_assert(int_array_pop_last(&array) == 1);
	z_assert(int_array_pop_last(&array) == 0);
	int_array_deinit(&array);
}

static void test_array_replace(void)
{
	struct int_array array;
	int_array_init(&array);
	int_array_append(&array, 0);
	int_array_append(&array, 1);
	int_array_append(&array, 0);
	z_assert(int_array_replace(&array, 0, 2) == 2);
	z_assert(int_array_get(&array, 0) == 2);
	z_assert(int_array_get(&array, 1) == 1);
	z_assert(int_array_get(&array, 2) == 2);
	z_assert(int_array_replace(&array, 0, 2) == 0);
	z_assert(int_array_replace(&array, 1, 1) == 1);
	int_array_deinit(&array);
}

static void test_array_reverse(void)
{
	struct int_array array;
	int_array_init(&array);
	int_array_reverse(&array);
	z_assert(int_array_len(&array) == 0);

	int_array_append(&array, 0);
	int_array_reverse(&array);
	z_assert(int_array_get(&array, 0) == 0);

	int_array_truncate(&array, 0);
	int_array_append(&array, 0);
	int_array_append(&array, 1);
	int_array_reverse(&array);
	z_assert(int_array_get(&array, 0) == 1);
	z_assert(int_array_get(&array, 1) == 0);

	int_array_truncate(&array, 0);
	int_array_append(&array, 0);
	int_array_append(&array, 1);
	int_array_append(&array, 2);
	int_array_reverse(&array);
	z_assert(int_array_get(&array, 0) == 2);
	z_assert(int_array_get(&array, 1) == 1);
	z_assert(int_array_get(&array, 2) == 0);

	int_array_deinit(&array);
}

static void test_array_rotate_right(void)
{
	struct int_array array;
	int_array_init(&array);

	z_assert(int_array_len(&array) == 0);
	int_array_append(&array, 1);
	int_array_append(&array, 2);
	z_assert(int_array_get(&array, 0) == 1);
	z_assert(int_array_get(&array, 1) == 2);
	int_array_rotate_right(&array);
	z_assert(int_array_get(&array, 0) == 2);
	z_assert(int_array_get(&array, 1) == 1);
	z_assert(int_array_len(&array) == 2);

	int_array_truncate(&array, 0);
	int_array_append(&array, 1);
	int_array_rotate_right(&array);
	z_assert(int_array_get(&array, 0) == 1);

	int_array_deinit(&array);
}

static void test_array_shrink(void)
{
	struct int_array array = Z_EMPTY_ARRAY;
	size_t i;
	size_t num_items_allocated;
	for (i = 0; i < 64; i++)
		z_assert(int_array_append(&array, (int) i));

	num_items_allocated = array.num_items_allocated;

	for (i = 0; i < 49; i++)
		z_assert(int_array_pop_last(&array) == (63 - (int) i));

	z_assert(array.num_items_allocated < num_items_allocated);

	int_array_deinit(&array);
}

static void shuffle_test(const size_t upper_bound)
{
	struct int_array array = Z_EMPTY_ARRAY;
	size_t i;
	struct z_random_state *rs = z_random_create_state();
	size_t *freq = calloc(upper_bound, sizeof freq[0]);
	z_assert_not_null(freq);
	for (i = 0; i < upper_bound; i++)
		z_assert(int_array_append(&array, (int) i));
	int_array_shuffle(&array, rs);
	for (i = 0; i < upper_bound; i++)
		freq[int_array_get(&array, i)]++;
	for (i = 0; i < upper_bound; i++)
		z_assert(freq[i] == 1);
	int_array_deinit(&array);
	free(freq);
	z_random_free_state(rs);
}

static void test_array_shuffle(void)
{
	size_t i;
	for (i = 0; i < 8; i++)
		shuffle_test(i);
}


static void test_array_truncate(void)
{
	struct int_array *array = int_array_create();
	int ints[3] = {1, 1, 1};
	array->items = ints;
	array->num_items_allocated = 3;
	z_assert(array->num_items == 0);
	z_assert(ints[0] == 1);
	z_assert(ints[1] == 1);
	int_array_truncate(array, 1);
	z_assert(array->num_items == 1);
	z_assert(ints[0] == 0);
	z_assert(ints[1] == 1);

	int_array_truncate(array, 0);
	z_assert(array->num_items == 0);
	z_assert(ints[0] == 0);
	z_assert(ints[1] == 1);

	array->items = NULL;
	int_array_free(array);
}

static void test_array2_compare(void)
{
	struct foo_array array = Z_EMPTY_ARRAY;
	struct foo x = {.x = 4};
	struct foo y = {.x = 3};
	struct foo z = {.x = -1};
	z_assert(foo_array_append(&array, x));
	z_assert(foo_array_get(&array, 0).x == 4);
	z_assert(foo_array_find(&array, (struct foo) {.x = 4}, 0) == 0);
	z_assert(foo_array_find(&array, (struct foo) {.x = 4}, 1) ==
		    (size_t) -1);
	z_assert(foo_array_find(&array, (struct foo) {.x = 3}, 0) ==
		    (size_t) -1);

	z_assert(foo_array_count(&array, (struct foo) {.x = 3}) == 0);
	z_assert(foo_array_count(&array, (struct foo) {.x = 4}) == 1);

	z_assert(foo_array_append(&array, y));
	z_assert(foo_array_append(&array, z));
	z_assert(foo_array_get(&array, 0).x == 4);
	foo_array_sort(&array);
	z_assert(foo_array_get(&array, 0).x == -1);
	z_assert(foo_array_get(&array, 1).x == 3);
	z_assert(foo_array_get(&array, 2).x == 4);

	foo_array_deinit(&array);
}

static void test_pair_array(void)
{
	struct pair_array array = Z_EMPTY_ARRAY;
	pair_array_init(&array);
	pair_array_append(&array, 0, 0.5);
	pair_array_append(&array, 1, 1.5);
	z_assert(pair_array_get0(&array, 0) == 0);
	z_assert(pair_array_get1(&array, 0) == 0.5);
	z_assert(pair_array_get0(&array, 1) == 1);
	z_assert(pair_array_get1(&array, 1) == 1.5);
	pair_array_deinit(&array);
}

static void test_pair_array_find(void)
{
	struct pair_array array = Z_EMPTY_ARRAY;
	pair_array_init(&array);
	pair_array_append(&array, 0, 0.5);
	pair_array_append(&array, 1, 1.5);
	z_assert(pair_array_find0(&array, 0, 0) == 0);
	z_assert(pair_array_find0(&array, 0, 1) == (size_t) -1);
	z_assert(pair_array_find0(&array, 1, 0) == 1);
	z_assert(pair_array_find0(&array, 1, 1) == 1);
	z_assert(pair_array_find0(&array, 1, 2) == (size_t) -1);
	z_assert(pair_array_find0(&array, 2, 0) == (size_t) -1);

	z_assert(pair_array_find1(&array, 0.5, 0) == 0);
	z_assert(pair_array_find1(&array, 0.5, 1) == (size_t) -1);
	z_assert(pair_array_find1(&array, 1.5, 0) == 1);
	z_assert(pair_array_find1(&array, 1.5, 1) == 1);
	z_assert(pair_array_find1(&array, 1.5, 2) == (size_t) -1);

	pair_array_deinit(&array);
}

static void test_pair_array_free(void)
{
	pair_array_free(NULL);
}

int main(void)
{
	test_array();
	test_array_choice();
	test_array_clone();
	test_array_count();
	test_array_create();
	test_array_create2();
	test_array_extend();
	test_array_free();
	test_array_insert();
	test_array_int_ptr();
	test_array_iter();
	test_array_pop_last();
	test_array_replace();
	test_array_reverse();
	test_array_rotate_right();
	test_array_shrink();
	test_array_shuffle();
	test_array_truncate();
	test_array2_compare();

	test_pair_array();
	test_pair_array_find();
	test_pair_array_free();

	return 0;
}
