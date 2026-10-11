#include <zakalwe/base.h>
#include <zakalwe/bitfield.h>
#include <zakalwe/mem.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void test_bf(void)
{
	size_t pos;
	size_t n;
	size_t s;
	struct z_bitfield *bf0 = z_bitfield_create(0);
	struct z_bitfield *bf1;
	z_assert(bf0 != NULL);
	z_bitfield_free_and_poison(bf0);

	bf0 = z_bitfield_create(1);
	z_assert(z_bitfield_get(bf0, 0) == 0);
	z_bitfield_set(bf0, 0, 0);
	z_bitfield_set(bf0, 0, 1);
	z_assert(z_bitfield_get(bf0, 0) == 1);
	z_bitfield_free_and_poison(bf0);

	bf0 = z_bitfield_create(8);
	z_assert(z_bitfield_get(bf0, 7) == 0);
	z_bitfield_set(bf0, 7, 1);
	z_assert(z_bitfield_get(bf0, 7) == 1);
	z_bitfield_free_and_poison(bf0);

	bf0 = z_bitfield_create(9);
	z_assert(z_bitfield_get(bf0, 8) == 0);
	z_bitfield_set(bf0, 8, 1);
	z_assert(z_bitfield_get(bf0, 8) == 1);
	z_bitfield_free_and_poison(bf0);

	n = 100;
	bf0 = z_bitfield_create(n);
	for (pos = 0; pos < n; pos++)
		z_bitfield_set(bf0, pos, pos & 1);
	s = 0;
	for (pos = 0; pos < n; pos++)
		s += z_bitfield_get(bf0, pos);
	z_assert(s == 50);
	z_bitfield_free_and_poison(bf0);

	bf0 = z_bitfield_create(9);
	z_bitfield_set(bf0, 1, 1);
	z_bitfield_set(bf0, 8, 1);
	bf1 = z_bitfield_clone(bf0);
	z_assert(bf1->n == bf0->n);
	s = (bf0->n + 7) >> 3;  /* byte size of the array inside */
	z_assert(memcmp(bf0->bits, bf1->bits, s) == 0);
	z_bitfield_free_and_poison(bf0);
	z_bitfield_free_and_poison(bf1);

	z_bitfield_free(NULL);
}

static void test_z_bitfield_copy_slice(void)
{
	struct z_bitfield *bf0 = z_bitfield_create(4);
	struct z_bitfield *bf1 = z_bitfield_create(4);
	size_t dst_start;
	size_t len;
	size_t i;
	z_assert(bf0 != NULL && bf1 != NULL);
	z_bitfield_set(bf0, 0, 1);
	z_bitfield_set(bf0, 1, 0);
	z_bitfield_set(bf0, 2, 1);
	z_bitfield_set(bf0, 3, 0);

	z_assert(z_bitfield_copy_slice(bf1, 4, bf0, 0, 0));
	z_assert(z_bitfield_copy_slice(bf1, 5, bf0, 0, 0));
	z_assert(z_bitfield_copy_slice(bf1, 0, bf0, 4, 0));
	z_assert(z_bitfield_copy_slice(bf1, 1, bf0, 5, 0));

	for (dst_start = 0; dst_start <= 4; dst_start++) {
		for (len = 0; len <= (4 - dst_start); len++) {
			z_bitfield_clear(bf1);
			z_assert(z_bitfield_copy_slice(bf1, dst_start, bf0, 0,
						   len));
			for (i = 0; i < len; i++) {
				z_assert(z_bitfield_get(bf0, i) ==
				       z_bitfield_get(bf1, dst_start + i));
			}
		}
		z_assert(z_bitfield_copy_slice(bf1, dst_start, bf0, 0, len) == 0);
	}

	z_bitfield_free_and_poison(bf0);
	z_bitfield_free_and_poison(bf1);
}

static void test_z_bitfield_set_from_args(void)
{
	struct z_bitfield *bf = z_bitfield_create(3);
	z_bitfield_set_from_args(bf, 1, 0, 1);
	z_assert(z_bitfield_get(bf, 0) == 1);
	z_assert(z_bitfield_get(bf, 1) == 0);
	z_assert(z_bitfield_get(bf, 2) == 1);
	z_bitfield_free_and_null(bf);
}

static void test_z_bitfield_copy(void)
{
	struct z_bitfield *bf0 = z_bitfield_create(4);
	struct z_bitfield *bf1 = z_bitfield_create(4);
	z_bitfield_set_from_args(bf0, 1, 0, 1, 0);
	z_bitfield_copy(bf1, bf0);
	z_assert(z_bitfield_get(bf1, 0) == 1);
	z_assert(z_bitfield_get(bf1, 1) == 0);
	z_assert(z_bitfield_get(bf1, 2) == 1);
	z_assert(z_bitfield_get(bf1, 3) == 0);
	z_bitfield_free_and_null(bf0);
	z_bitfield_free_and_null(bf1);
}

static void test_z_bitfield_equals(void)
{
	struct z_bitfield *bf0;
	struct z_bitfield *bf1;
	bf0 = z_bitfield_create(0);
	bf1 = z_bitfield_create(0);
	z_assert(bf0 != NULL && bf1 != NULL);
	z_assert(z_bitfield_equals(bf0, bf1) == 1);
	z_bitfield_free_and_null(bf0);
	z_bitfield_free_and_null(bf1);

	bf0 = z_bitfield_create(1);
	bf1 = z_bitfield_create(1);
	z_assert(bf0 != NULL && bf1 != NULL);
	z_assert(z_bitfield_equals(bf0, bf1) == 1);
	z_bitfield_set(bf0, 0, 1);
	z_assert(z_bitfield_equals(bf0, bf1) == 0);
	z_bitfield_set(bf1, 0, 1);
	z_assert(z_bitfield_equals(bf0, bf1) == 1);
	z_bitfield_free_and_null(bf0);
	z_bitfield_free_and_null(bf1);

	bf0 = z_bitfield_create(4);
	bf1 = z_bitfield_create(4);
	z_assert(bf0 != NULL && bf1 != NULL);
	z_assert(z_bitfield_equals(bf0, bf1) == 1);
	z_bitfield_set(bf0, 0, 1);
	z_assert(z_bitfield_equals(bf0, bf1) == 0);
	z_bitfield_set(bf1, 0, 1);
	z_assert(z_bitfield_equals(bf0, bf1) == 1);
	z_bitfield_set(bf0, 1, 1);
	z_assert(z_bitfield_equals(bf0, bf1) == 0);
	z_bitfield_set(bf1, 1, 1);
	z_assert(z_bitfield_equals(bf0, bf1) == 1);
	z_bitfield_set(bf0, 3, 1);
	z_assert(z_bitfield_equals(bf0, bf1) == 0);
	z_bitfield_set(bf1, 3, 1);
	z_assert(z_bitfield_equals(bf0, bf1) == 1);
	z_bitfield_free_and_null(bf0);
	z_bitfield_free_and_null(bf1);

	bf0 = z_bitfield_create(8);
	bf1 = z_bitfield_create(8);
	z_assert(bf0 != NULL && bf1 != NULL);
	z_assert(z_bitfield_equals(bf0, bf1) == 1);
	z_bitfield_set(bf0, 0, 1);
	z_assert(z_bitfield_equals(bf0, bf1) == 0);
	z_bitfield_set(bf1, 0, 1);
	z_assert(z_bitfield_equals(bf0, bf1) == 1);
	z_bitfield_set(bf0, 1, 1);
	z_assert(z_bitfield_equals(bf0, bf1) == 0);
	z_bitfield_set(bf1, 1, 1);
	z_assert(z_bitfield_equals(bf0, bf1) == 1);
	z_bitfield_set(bf0, 7, 1);
	z_assert(z_bitfield_equals(bf0, bf1) == 0);
	z_bitfield_set(bf1, 7, 1);
	z_assert(z_bitfield_equals(bf0, bf1) == 1);
	z_bitfield_free_and_null(bf0);
	z_bitfield_free_and_null(bf1);

	bf0 = z_bitfield_create(9);
	bf1 = z_bitfield_create(9);
	z_assert(bf0 != NULL && bf1 != NULL);
	z_assert(z_bitfield_equals(bf0, bf1) == 1);
	z_bitfield_set(bf0, 0, 1);
	z_assert(z_bitfield_equals(bf0, bf1) == 0);
	z_bitfield_set(bf1, 0, 1);
	z_assert(z_bitfield_equals(bf0, bf1) == 1);
	z_bitfield_set(bf0, 1, 1);
	z_assert(z_bitfield_equals(bf0, bf1) == 0);
	z_bitfield_set(bf1, 1, 1);
	z_assert(z_bitfield_equals(bf0, bf1) == 1);
	z_bitfield_set(bf0, 8, 1);
	z_assert(z_bitfield_equals(bf0, bf1) == 0);
	z_bitfield_set(bf1, 8, 1);
	z_assert(z_bitfield_equals(bf0, bf1) == 1);
	z_bitfield_free_and_null(bf0);
	z_bitfield_free_and_null(bf1);
}

static void test_z_bitfield_l2_metric(void)
{
	struct z_bitfield *a = z_bitfield_create(2);
	struct z_bitfield *b = z_bitfield_create(2);
	struct z_bitfield *c = z_bitfield_create(3);
	struct z_bitfield *d = z_bitfield_create(4);
	z_assert(a != NULL && b != NULL && c != NULL && d != NULL);
	z_bitfield_set_from_args(a, 1, 0);
	z_bitfield_set_from_args(b, 0, 1);
	z_bitfield_set_from_args(c, 1, 0, 0);
	z_bitfield_set_from_args(d, 1, 0, 0, 1);
	z_assert(z_bitfield_l2_metric(a, a) == 0);
	z_assert(z_bitfield_l2_metric(a, b) == 2);
	z_assert(z_bitfield_l2_metric(a, c) == 0);
	z_assert(z_bitfield_l2_metric(a, d) == 1);
	z_assert(z_bitfield_l2_metric(b, d) == 3);
	z_bitfield_free(a);
	z_bitfield_free(b);
	z_bitfield_free(c);
	z_bitfield_free(d);
}

static void test_z_bitfield_xor(void)
{
	struct z_bitfield *a = z_bitfield_create(2);
	struct z_bitfield *b = z_bitfield_create(2);
	struct z_bitfield *c = z_bitfield_create(2);
	struct z_bitfield *d = z_bitfield_create(3);
	z_bitfield_set_from_args(a, 1, 0);
	z_bitfield_set_from_args(b, 0, 1);
	z_assert(z_bitfield_xor(c, a, b));
	z_assert(z_bitfield_get(c, 0) == 1);
	z_assert(z_bitfield_get(c, 1) == 1);

	z_assert(z_bitfield_xor(c, c, c));
	z_assert(z_bitfield_get(c, 0) == 0);
	z_assert(z_bitfield_get(c, 1) == 0);

	z_assert(z_bitfield_xor(c, c, b));
	z_assert(z_bitfield_get(c, 0) == 0);
	z_assert(z_bitfield_get(c, 1) == 1);

	z_assert_false(z_bitfield_xor(c, d, b));
	z_assert_false(z_bitfield_xor(c, a, d));
	z_assert_false(z_bitfield_xor(d, a, b));

	z_bitfield_free(a);
	z_bitfield_free(b);
	z_bitfield_free(c);
	z_bitfield_free(d);
}

int main(void)
{
	test_bf();
	test_z_bitfield_copy();
	test_z_bitfield_copy_slice();
	test_z_bitfield_equals();
	test_z_bitfield_set_from_args();
	test_z_bitfield_l2_metric();
	test_z_bitfield_xor();
	return 0;
}
