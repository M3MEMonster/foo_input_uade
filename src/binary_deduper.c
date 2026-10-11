/*
 * A module that can be used to track if a duplicate byte sequence is
 * observed over time.
 */
#include "sysconfig.h"
#include "sysdeps.h"
#include "memory.h"
#include "binary_deduper.h"

#include <string.h>

#include "zakalwe/array.h"
#include "zakalwe/map.h"

struct binary_deduper_key {
	size_t size;
	unsigned char data[];
};

static int binary_cmp(const struct binary_deduper_key *x,
		      const struct binary_deduper_key *y)
{
	size_t compare_size = Z_MIN(x->size, y->size);
	int ret = memcmp(x->data, y->data, compare_size);
	if (ret == 0 && x->size != y->size) {
		/*
		 * The smallest comes first. We don't actually have this
		 * use-case.
		 */
		ret = (x->size < y->size) ? -1 : 1;
	}
	return ret;
}

Z_MAP_PROTOTYPE(binary_deduper_map, struct binary_deduper_key *, int, binary_cmp)

struct binary_deduper {
	struct binary_deduper_map *map;
};

static void free_key(struct binary_deduper_key *key)
{
	z_zero_target(key);
	free(key);
}

struct binary_deduper *uade_binary_deduper_create(void)
{
	struct binary_deduper *bd = z_calloc_target(bd);
	if (bd == NULL) {
		fprintf(stderr, "binary deduper: out of memory");
		return NULL;
	}
	bd->map = binary_deduper_map_create();
	if (bd->map == NULL) {
		fprintf(stderr, "binary deduper: out of memory");
		free(bd);
		return NULL;
	}
	binary_deduper_map_cleanup_keys(bd->map, free_key);
	return bd;
}

void uade_binary_deduper_reset(struct binary_deduper *bd)
{
	binary_deduper_map_clear(bd->map);
}

static struct binary_deduper_key *alloc_key(const size_t size)
{
	struct binary_deduper_key *key = calloc(1, sizeof(*key) + size);
	if (key != NULL) {
		key->size = size;
	}
	return key;
}

int uade_binary_deduper_add(struct binary_deduper *bd, const void *data,
			    const size_t size)
{
	/* Returns 0 if data is a duplicate. Otherwise returns 1. */
	struct binary_deduper_key *key = alloc_key(size);
	if (key == NULL) {
		fprintf(stderr, "binary deduper: out of memory");
		/* Out-of-memory -> end detection does not work -> return "ok". */
		return 1;
	}
	memcpy(key->data, data, key->size);

        if (binary_deduper_map_len(bd->map) >= (3600 * 50)) {
            /*
             * Avoid infinite memory consumption in-case there is a bug.
             * Store at most one hour worth of binary data.
             * Return "ok".
             */
            return 1;
        }

	if (binary_deduper_map_has(bd->map, key)) {
            /* duplicate detected */
            return 0;
        }

	if (!binary_deduper_map_set(bd->map, key, 1)) {
		fprintf(stderr, "binary deduper: out of memory");
		z_free_and_null(key);
	}

	return 1;
}
