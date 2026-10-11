#include <zakalwe/base.h>
#include <zakalwe/endianess.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void test_endianess_0(void)
{
	unsigned char mem[8];
	const float floats0[2] = {1.0f, 2.0f};
	float floats1[2];
	const uint64_t u = 0x0123456789abcdefULL;

	memset(mem, 0, sizeof(mem));
	z_write_u16_be(mem, 0x0123);
	z_assert(mem[0] == 0x01);
	z_assert(mem[1] == 0x23);
	memset(mem, 0, sizeof(mem));
	z_write_s16_be(mem, 0x0123);
	z_assert(mem[0] == 0x01);
	z_assert(mem[1] == 0x23);

	memset(mem, 0, sizeof(mem));
	z_write_u32_be(mem, 0x01234567);
	z_assert(mem[0] == 0x01);
	z_assert(mem[1] == 0x23);
	z_assert(mem[2] == 0x45);
	z_assert(mem[3] == 0x67);
	memset(mem, 0, sizeof(mem));
	z_write_s32_be(mem, 0x01234567);
	z_assert(mem[0] == 0x01);
	z_assert(mem[1] == 0x23);
	z_assert(mem[2] == 0x45);
	z_assert(mem[3] == 0x67);

	memset(mem, 0, sizeof(mem));
	z_write_u64_be(mem, u);
	z_assert(mem[0] == 0x01);
	z_assert(mem[1] == 0x23);
	z_assert(mem[2] == 0x45);
	z_assert(mem[3] == 0x67);
	z_assert(mem[4] == 0x89);
	z_assert(mem[5] == 0xab);
	z_assert(mem[6] == 0xcd);
	z_assert(mem[7] == 0xef);
	memset(mem, 0, sizeof(mem));
	z_write_s64_be(mem, u);
	z_assert(mem[0] == 0x01);
	z_assert(mem[1] == 0x23);
	z_assert(mem[2] == 0x45);
	z_assert(mem[3] == 0x67);
	z_assert(mem[4] == 0x89);
	z_assert(mem[5] == 0xab);
	z_assert(mem[6] == 0xcd);
	z_assert(mem[7] == 0xef);

	memset(mem, 0, sizeof(mem));
	z_write_u16_le(mem, 0x0123);
	z_assert(mem[0] == 0x23);
	z_assert(mem[1] == 0x01);
	memset(mem, 0, sizeof(mem));
	z_write_s16_le(mem, 0x0123);
	z_assert(mem[0] == 0x23);
	z_assert(mem[1] == 0x01);

	memset(mem, 0, sizeof(mem));
	z_write_u32_le(mem, 0x01234567);
	z_assert(mem[0] == 0x67);
	z_assert(mem[1] == 0x45);
	z_assert(mem[2] == 0x23);
	z_assert(mem[3] == 0x01);
	memset(mem, 0, sizeof(mem));
	z_write_s32_le(mem, 0x01234567);
	z_assert(mem[0] == 0x67);
	z_assert(mem[1] == 0x45);
	z_assert(mem[2] == 0x23);
	z_assert(mem[3] == 0x01);

	memset(mem, 0, sizeof(mem));
	z_write_u64_le(mem, u);
	z_assert(mem[0] == 0xef);
	z_assert(mem[1] == 0xcd);
	z_assert(mem[2] == 0xab);
	z_assert(mem[3] == 0x89);
	z_assert(mem[4] == 0x67);
	z_assert(mem[5] == 0x45);
	z_assert(mem[6] == 0x23);
	z_assert(mem[7] == 0x01);
	memset(mem, 0, sizeof(mem));
	z_write_s64_le(mem, u);
	z_assert(mem[0] == 0xef);
	z_assert(mem[1] == 0xcd);
	z_assert(mem[2] == 0xab);
	z_assert(mem[3] == 0x89);
	z_assert(mem[4] == 0x67);
	z_assert(mem[5] == 0x45);
	z_assert(mem[6] == 0x23);
	z_assert(mem[7] == 0x01);

	memset(mem, 0, sizeof(mem));
	z_write_floats_be((float *) mem, floats0, 2);
	z_assert(mem[0] == 0x3f);
	z_assert(mem[1] == 0x80);
	z_assert(mem[2] == 0x00);
	z_assert(mem[3] == 0x00);
	z_assert(mem[4] == 0x40);
	z_assert(mem[5] == 0x00);
	z_assert(mem[6] == 0x00);
	z_assert(mem[7] == 0x00);
	z_read_floats_be(floats1, mem, 2);
	z_assert(memcmp(floats0, floats1, sizeof(floats0)) == 0);

	memset(mem, 0, sizeof(mem));
	z_write_floats_le((float *) mem, floats0, 2);
	z_assert(mem[0] == 0x00);
	z_assert(mem[1] == 0x00);
	z_assert(mem[2] == 0x80);
	z_assert(mem[3] == 0x3f);
	z_assert(mem[4] == 0x00);
	z_assert(mem[5] == 0x00);
	z_assert(mem[6] == 0x00);
	z_assert(mem[7] == 0x40);
	z_read_floats_le(floats1, mem, 2);
	z_assert(memcmp(floats0, floats1, sizeof(floats0)) == 0);
}

static void test_read_0(void)
{
	unsigned char mem[8] = {0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87};
	z_assert(z_read_s16_be(mem) == ((int16_t) 0x8081));
	z_assert(z_read_s16_le(mem) == ((int16_t) 0x8180));
	z_assert(z_read_s32_be(mem) == ((int32_t) 0x80818283));
	z_assert(z_read_s32_le(mem) == ((int32_t) 0x83828180));
	z_assert(z_read_s64_be(mem) == ((int64_t) 0x8081828384858687LL));
	z_assert(z_read_s64_le(mem) == ((int64_t) 0x8786858483828180LL));

	z_assert(z_read_u16_be(mem) == 0x8081);
	z_assert(z_read_u16_le(mem) == 0x8180);
	z_assert(z_read_u32_be(mem) == 0x80818283);
	z_assert(z_read_u32_le(mem) == 0x83828180);
	z_assert(z_read_u64_be(mem) == 0x8081828384858687LL);
	z_assert(z_read_u64_le(mem) == 0x8786858483828180LL);
}


int main(void)
{
	test_endianess_0();
	test_read_0();
	return 1;
}
