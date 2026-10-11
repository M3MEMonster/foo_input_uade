#include <string.h>

char* strsep(char** stringp, const char* delim) {
	if (stringp == NULL || *stringp == NULL || delim == NULL) return NULL;
	char* begin = *stringp;
	char* end = begin + strcspn(begin, delim);
	if (*end != '\0') {
		*end = '\0';
		*stringp = end + 1;
	}
	else {
		*stringp = NULL;
	}
	return begin;
}