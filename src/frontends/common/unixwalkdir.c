#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <windows.h>

#include "unixwalkdir.h"
#include "stringcvt.h"

void *uade_walk_directories(const char *dirname,
			    void *(*fn) (const char *file,
					 enum uade_wtype wtype, void *opaque),
			    void *opaque)
{
	char *dename;
	HANDLE hFile;
	WIN32_FIND_DATA pNextInfo;
	size_t namelen;
	void *ret = NULL;
	enum uade_wtype wtype;

	namelen = strlen(dirname) + 256 + 2;
	if ((dename = malloc(namelen)) == NULL)
		return NULL;
	wchar_t pattern[8192];
	wchar_t wchr_dirname[4096];
	wchar_t wchr_sep[4096];
	size_t len = strlen(dirname);
	char* separator = len > 0 && (dirname[len - 1] == '/' || dirname[len - 1] == '\\') ? "" : "\\";
	CtoW(dirname, wchr_dirname);
	CtoW(separator, wchr_sep);
	swprintf_s(pattern, _countof(pattern), L"%ls%ls*", wchr_dirname, wchr_sep);
	hFile = FindFirstFileW(pattern, &pNextInfo);
	if (hFile==INVALID_HANDLE_VALUE)
		goto err;

	do {
		char chr_fileName[4096];
		WtoC(pNextInfo.cFileName, chr_fileName);
		if (strcmp(chr_fileName, ".") == 0
		    || strcmp(chr_fileName, "..") == 0)
			continue;

		if (snprintf(dename, namelen, "%s/%s", dirname, chr_fileName) >=
		    namelen) {
			fprintf(stderr, "interesting: too long a filename\n");
			continue;
		}

		DWORD attributes = pNextInfo.dwFileAttributes;
		if (attributes & FILE_ATTRIBUTE_REPARSE_POINT) {
			wtype = UADE_WALK_SYMLINK;
		}
		else if (attributes & FILE_ATTRIBUTE_DIRECTORY) {
			wtype = UADE_WALK_DIRECTORY;
		}
		else {
			wtype = UADE_WALK_REGULAR_FILE;
		}

		if ((ret = fn(dename, wtype, opaque)) != NULL)
			break;

		if (wtype == UADE_WALK_DIRECTORY) {
			if ((ret =
			     uade_walk_directories(dename, fn, opaque)) != NULL)
				break;
		}
	} while (FindNextFileW(hFile, &pNextInfo));

	FindClose(hFile);
err:
	free(dename);

	return ret;
}
