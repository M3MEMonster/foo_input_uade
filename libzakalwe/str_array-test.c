#include <zakalwe/str_array.h>

static void test_str_array(void)
{
	struct str_array array = Z_EMPTY_ARRAY;
	z_assert(str_array_append(&array, strdup("0")));
	z_assert(str_array_append(&array, strdup("1")));
	z_assert(strcmp(str_array_get(&array, 0), "0") == 0);
	z_assert(strcmp(str_array_get(&array, 1), "1") == 0);
	str_array_free_elements(&array);
	z_assert(str_array_len(&array) == 0);
	str_array_deinit(&array);

	struct str_array *array2 = str_array_create();
	z_assert(array2 != NULL);
	z_assert(str_array_append(array2, strdup("0")));
	z_assert(str_array_append(array2, strdup("1")));
	z_assert(strcmp(str_array_get(array2, 0), "0") == 0);
	z_assert(strcmp(str_array_get(array2, 1), "1") == 0);
	str_array_free_all(array2);
}


int main(void)
{
	test_str_array();
}
