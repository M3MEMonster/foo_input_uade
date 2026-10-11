#include <zakalwe/base.h>
#include <zakalwe/time.h>

#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <unistd.h>

static void test_timeval_delta(void)
{
	z_assert(z_timeval_delta(
			    & (struct timeval) {.tv_sec = 0},
			    & (struct timeval) {.tv_sec = 0}) ==
		    0);

	z_assert(z_timeval_delta(
			    & (struct timeval) {.tv_sec = 1000000000},
			    & (struct timeval) {.tv_sec = 0}) ==
		    (1000000000LL * 1000000));

	z_assert(z_timeval_delta(
			    & (struct timeval) {.tv_sec = 1000000000},
			    & (struct timeval) {.tv_usec = 1}) ==
		    (1000000000LL * 1000000 - 1));

	z_assert(z_timeval_delta(
			    & (struct timeval) {.tv_sec = 1000000000,
					        .tv_usec = 1},
			    & (struct timeval) {.tv_sec = 0}) ==
		    (1000000000LL * 1000000 + 1));

	z_assert(z_timeval_delta(
			    & (struct timeval) {.tv_sec = 1000000000},
			    & (struct timeval) {.tv_sec = -1}) ==
		    INT64_MIN);
	z_assert(z_timeval_delta(
			    & (struct timeval) {.tv_sec = -1},
			    & (struct timeval) {.tv_sec = 0}) ==
		    INT64_MIN);

	z_assert(z_timeval_delta(
			    & (struct timeval) {.tv_usec = -1},
			    & (struct timeval) {.tv_usec = 0}) ==
		    INT64_MIN);
	z_assert(z_timeval_delta(
			    & (struct timeval) {.tv_usec = 0},
			    & (struct timeval) {.tv_usec = -1}) ==
		    INT64_MIN);
}

static void test_timeval_delta_and_set(void)
{
	struct timeval tv0;
	double t0;
	double t1;
	double delta;
	assert(!gettimeofday(&tv0, NULL));
	t0 = ((double) tv0.tv_sec) + 0.000001 * tv0.tv_usec;
	t1 = z_timeval_delta_and_set(NULL);
	assert(t0 <= t1);
	usleep(1000);
	delta = z_timeval_delta_and_set(&tv0);
	/* This may be an unreliable test */
	assert(delta >= 0.001);
	usleep(1000);
	delta = z_timeval_delta_and_set(&tv0);
	assert(delta >= 0.001);
}

int main(void)
{
	test_timeval_delta();
	test_timeval_delta_and_set();
	return 0;
}
