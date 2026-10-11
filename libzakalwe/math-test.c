#include <zakalwe/math.h>
#include <zakalwe/base.h>

#include <math.h>

static void test_logistic_function_f(void)
{
	float table[][2] = {
		{0.0f, 0.5f},
		{0.0f, -1.0f},
	};
	int i;
	for (i = 0;; i++) {
		float x = table[i][0];
		float y = table[i][1];
		float v;
		if (y < 0.0)
			break;
		v = z_logistic_function_f(x);
		z_assert(fabs(v - y) < 1E-6);
	}
	z_assert(z_logistic_function_f(-17 - 0.000001) == 0.0);
	z_assert(z_logistic_function_f(17 + 0.000001) == 1.0);
}

void test_rectified_linear_activation_f(void);

void test_rectified_linear_activation_f(void)
{
	float table[][2] = {
		{-10.0f, 0.0f},
		{-1.0f, 0.0f},
		{-0.1f, 0.0f},
		{0.0f, 0.0f},
		{0.1f, 0.1f},
		{0.5f, 0.5f},
		{1.0f, 1.0f},
		{2.0f, 2.0f},
		{0.0f, -1.0f},
	};
	int i;
	for (i = 0;; i++) {
		float x = table[i][0];
		float y = table[i][1];
		float v;
		if (y < 0.0)
			break;
		v = z_rectified_linear_activation_f(x);
		z_assert(fabs(v - y) < 1E-6);
	}
}

static void test_mul2_size_t(void)
{
	size_t table[][4] = {
		{0, 1, 0, 1},
		{1, 0, 0, 1},
		{0, -1, 0, 1},
		{-1, 0, 0, 1},
		{1, 2, 2, 1},
		{2, 3, 6, 1},
		{1, -1, -1, 1},
		{-1, 1, -1, 1},
		{1, -1, -1, 1},
		{((size_t) -1) / 2, 2, -2, 1},
		{((size_t) -1) / 4, 4, -4, 1},
		{2, ((size_t) -1) / 2, -2, 1},
		{4, ((size_t) -1) / 4, -4, 1},
		/* overflowing results */
		{2, -1, 0, 0},
		{-1, 2, 0, 0},
		{0, 0, 0, -1},
	};
	int i;
	for (i = 0;; i++) {
		size_t result;
		size_t a = table[i][0];
		size_t b = table[i][1];
		size_t expected_result = table[i][2];
		int expected_success = table[i][3];
		int success;
		if (expected_success == -1)
			break;
		success = z_mul2_size_t(&result, a, b);
		z_assert(success == expected_success);
		z_assert(result == expected_result);
	}
}

int main(void)
{
	test_logistic_function_f();
	test_rectified_linear_activation_f();
	test_mul2_size_t();
	return 0;
}
