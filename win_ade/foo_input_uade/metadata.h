#pragma once
#include <iostream>

#pragma pack(push,1)
typedef struct _MetadataEntry {
	uint64_t md5;
	uint32_t offset;
	uint16_t str_length;
} MetadataEntry;
#pragma pack(pop)

typedef struct _metadata_header {
	char magic[8];
	uint32_t entry_count;
	uint32_t string_table_start;
} metadata_header;