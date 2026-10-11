#ifndef _UADE_BINARY_DEDUPER_H_
#define _UADE_BINARY_DEDUPER_H_

#include "sysdeps.h"

struct binary_deduper;

struct binary_deduper *uade_binary_deduper_create(void);
int uade_binary_deduper_add(struct binary_deduper *bd, const void *mem,
                            const size_t size);
void uade_binary_deduper_reset(struct binary_deduper *bd);

#endif
