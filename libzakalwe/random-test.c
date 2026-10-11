#include <zakalwe/math.h>
#include <zakalwe/mem.h>
#include <zakalwe/random.h>
#include <zakalwe/base.h>

#include <math.h>

static void test_fast_normal_random(void)
{
	size_t i;
	float p;
	struct z_random_state *randstate = z_random_create_state();
	double sum;
	const float mean = 100.0;
	const float std = 15.0;
	double computed_std;

	z_assert(randstate != NULL);
	z_assert(z_float_equal(z_lookup_normal_random_table(0), -4.169573, 0.000001));
	z_assert(z_float_equal(z_lookup_normal_random_table(32767), -1.9124e-5,
			   0.000001));
	z_assert(z_float_equal(z_lookup_normal_random_table(32768), 1.9124e-5,
			   0.000001));
	z_assert(z_float_equal(z_lookup_normal_random_table(65535), 4.169573,
			   0.000001));
	p = z_lookup_normal_random_table(0);
	for (i = 1; i < 65536; i++) {
		float new_p = z_lookup_normal_random_table(i);
		z_assert(p < new_p);
		p = new_p;
	}

	sum = 0.0;
	for (i = 0; i < 10000; i++) {
		double r = z_fast_normal_random(randstate, mean, std);
		sum += (r - mean) * (r - mean);
	}
	computed_std = sqrt(sum / 10000);
	z_assert(z_float_equal(computed_std, std, 1));

	z_random_free_state(randstate);
}

static void test_random_double(void)
{
	struct z_random_state *rs;
	int i;
	double v;
	double d;
	double max = 0;
	double min = 1;
	rs = z_random_create_state();
	z_assert(rs != NULL);
	v = z_random_double(rs);
	for (i = 0; i < 2; i++) {
		double nv = z_random_double(rs);
		if (nv != v)
			break;
	}
	z_assert(i < 2);
	d = 0.0;
	for (i = 0; i < 10000; i++) {
		double nv = z_random_double(rs);
		z_assert(nv >= 0);
		z_assert(nv < 1.0);
		max = Z_MAX(max, nv);
		min = Z_MIN(min, nv);
		d += nv;
	}
	d /= 10000;
	/* This is a fuzzy test. */
	z_assert(fabs(d - 0.5) < 0.1);
	z_assert(min < 0.01);
	z_assert(max > 0.99);
	z_free_and_poison(rs);
}

static void test_random_float(void)
{
	struct z_random_state *rs;
	int i;
	float v;
	double d;
	rs = z_random_create_state();
	z_assert(rs != NULL);
	v = z_random_float(rs);
	for (i = 0; i < 2; i++) {
		float nv = z_random_float(rs);
		if (nv != v)
			break;
	}
	z_assert(i < 2);
	d = 0.0;
	for (i = 0; i < 10000; i++)
		d += z_random_float(rs);
	d /= 10000;
	z_assert(fabs(d - 0.5) < 0.1);
	z_free_and_poison(rs);
}

static void test_random_uint32(void)
{
	struct z_random_state *rs;
	int i;
	double d;
	uint32_t v;
	rs = z_random_create_state();
	z_assert(rs != NULL);
	v = z_random_uint32(rs);
	for (i = 0; i < 2; i++) {
		uint32_t nv = z_random_uint32(rs);
		if (nv != v)
			break;
	}
	z_assert(i < 2);

	d = 0.0;
	for (i = 0; i < 10000; i++) {
		d += ((double) z_random_uint32(rs)) / (1ULL << 31);
	}
	d /= 10000;
	z_assert(fabs(d - 1.0) < 0.90);
	z_free_and_poison(rs);
}

static void test_random_size_t_by_weights(void)
{
	struct z_random_state *rs;
	size_t i;
	const size_t num_weights = 3;
	float w[3] = {1, 10, 100};
	size_t freq[3] = {0, 0, 0};
	rs = z_random_create_state();
	z_assert(rs != NULL);
	for (i = 0; i < 10000; i++) {
		size_t x = z_random_size_t_by_weights(w, num_weights, rs);
		z_assert(x < num_weights);
		freq[x]++;
	}
	/* TODO: Derive the safety ranges by using normal distribution */
	z_assert(45 <= freq[0] && freq[0] <= 180);
	z_assert(800 <= freq[1] && freq[1] <= 1000);
	z_assert(8900 <= freq[2] && freq[2] <= 9100);
	z_random_free_state(rs);
}

static int find_size_t(const size_t *order, const size_t n, const size_t x)
{
	size_t i;
	for (i = 0; i < n; i++) {
		if (order[i] == x)
			return 1;
	}
	return 0;
}

static void test_random_shuffle(void)
{
	struct z_random_state *rs = z_random_create_state();
	size_t order[3];
	const size_t n = 3;
	z_assert(rs != NULL);
	z_random_permutation(order, n, rs);
	z_assert(find_size_t(order, n, 0));
	z_assert(find_size_t(order, n, 1));
	z_assert(find_size_t(order, n, 2));
	z_random_permutation(order, 1, rs);
	z_assert(order[0] == 0);
	z_random_free_state(rs);
}

int main(void)
{
	test_fast_normal_random();
	test_random_double();
	test_random_float();
	test_random_uint32();
	test_random_size_t_by_weights();
	test_random_shuffle();
	return 0;
}
