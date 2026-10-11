#ifndef _UADE_WRITE_AUDIO_COMMON_H_
#define _UADE_WRITE_AUDIO_COMMON_H_

#include <cstdio>
#include <cstdlib>

#define UADE_RET_QUIT 16
#define UADE_RET_NEXT 17
#define UADE_RET_INVALID_SONG 18


#define CHECK(cond) do {                        \
	if (!(cond)) { \
		fprintf(stderr, "\nCHECK failed for condition " #cond " on %s:%d\n", __FILE__, __LINE__); \
		abort();				                   \
	} \
} while (0)

#endif
