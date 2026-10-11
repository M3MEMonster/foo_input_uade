#include <stdio.h>

void* memmem(const void* haystack, size_t haystack_len, const void* needle, size_t needle_len) {
	if (!needle || !needle_len) return haystack;
	if (!haystack || !haystack_len || needle_len > haystack_len) return NULL;
	const char* _temp_haystack = (const char*)haystack;
	const char* _temp_needle = (const char*)needle;
	for (size_t i = 0; i <= haystack_len - needle_len; i++) {
		for (size_t j = 0, count=0; j < needle_len; j++) {
			if (_temp_haystack[i + j] != _temp_needle[j]) break;
			count++;
			if (count == needle_len) return _temp_haystack + i;
		}
	}
	return NULL;
}

