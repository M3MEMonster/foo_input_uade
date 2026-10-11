#pragma once
#include <iostream>

typedef struct _SonglengthEntry {
	uint64_t md5;
	uint32_t offset;
	uint16_t min_subsong;
	uint16_t subsong_count;
} SonglengthEntry;

typedef struct _songlength_header {
	char magic[8];
	uint32_t entry_count;
	uint32_t duration_table_start;
} songlength_header;


