#include <cassert>
#include <cstdlib>
#include <cstdio>
#include <cstring>
#include <time.h>
#include <immintrin.h>
#include <stdint.h>
#include <math.h>

#include "uadegl.h"

using uade::write_audio::uadegl::avx2_4x4_u8_block_avg;

static uint64_t get_time_us()
{
	struct timespec tp;
	int ret = clock_gettime(CLOCK_MONOTONIC, &tp);
	assert(ret == 0);
	return ((uint64_t) tp.tv_sec) * 1000000 + tp.tv_nsec / 1000;
}

int main(void)
{
	const int width = 1920;
	const int height = 1080;
	const int aa_factor = 4;
	const int fb_size = width * height * 4;
	const int aa_fb_size = width * height * 4 * aa_factor * aa_factor;

	uint32_t *aa_fb = (uint32_t *) malloc(aa_fb_size);
	uint32_t *fb = (uint32_t *) malloc(fb_size);
	assert(aa_fb != nullptr);
	assert(fb != nullptr);
	memset(aa_fb, -1, aa_fb_size);

	uint64_t t0 = get_time_us();

	const uint32_t aa_stride = 4 * width * sizeof(aa_fb[0]);

	for (int y = 0; y < height; y++) {
		for (int x = 0; x < width; x++) {
			const int aa_offset = y * 4 * (width * 4) + x * 4;
			const uint32_t *block = aa_fb + aa_offset;
			const uint32_t avg = avx2_4x4_u8_block_avg(
				(const unsigned char *) block,
				0, aa_stride, aa_stride * 2, aa_stride * 3);
			fb[y * width + x] = avg;
		}
	}
	printf("time %zuus\n", get_time_us() - t0);

	free(fb);
	free(aa_fb);
	fb = NULL;
	aa_fb = NULL;
	return 0;
}
