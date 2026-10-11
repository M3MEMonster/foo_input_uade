#include <immintrin.h>
#include <stdint.h>
#include <string.h>

int main(void)
{
	unsigned char buf[32];
	memset(buf, 0, sizeof(buf));
	__m128i r0_128 = _mm_lddqu_si128((__m128i const *) buf);
	__m256i r0 = _mm256_cvtepu8_epi16(r0_128);
	__m256i s0 = _mm256_add_epi16(r0, r0);
	__m256i s1 = _mm256_permute4x64_epi64(s0, 0x01);
	(void) s1;
	s0 = _mm256_srli_epi16(s0, 4);
	s0 = _mm256_packus_epi16(s0, s0);
	uint32_t x = _mm256_extract_epi32(s0, 0);
	(void) x;
	return 0;
}
