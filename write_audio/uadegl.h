#ifndef _UADE_WRITE_AUDIO_UADEGL_H_
#define _UADE_WRITE_AUDIO_UADEGL_H_

#include "../src/frontends/include/uade/options.h"

#include <vector>
#include <cstdint>

#ifdef UADE_CONFIG_HAVE_MARCH_AVX2
#include <immintrin.h>
#endif

namespace uade {
namespace write_audio {
namespace uadegl {

void draw_line(std::vector<uint32_t> *fb,
	       int x0, int y0,
	       int x1, int y1,
	       uint32_t color,
	       int width,
	       int height);

void draw_line_aa(std::vector<uint32_t> *fb,
                  const float x0, const float y0,
                  const float x1, const float y1,
                  const uint32_t color,
                  const float line_width,
                  const int width, const int height);

void shrink_aa_framebuffer(
	std::vector<uint32_t> *fb,
	const std::vector<uint32_t> *aa_fb,
	const int width,
	const int height,
	const int aa_factor);

#ifdef UADE_CONFIG_HAVE_MARCH_AVX2
uint32_t avx2_4x4_u8_block_avg(const unsigned char *pix,
                               uint32_t off0, uint32_t off1,
                               uint32_t off2, uint32_t off3);
#endif

}  // namespace uadegl
}  // namespace write_audio
}  // namespace uade

#endif
