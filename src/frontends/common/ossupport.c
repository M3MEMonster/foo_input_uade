

/* UNIX support tools

   Copyright 2000-2011 (C) Heikki Orsila <heikki.orsila@iki.fi>
   
   This module is licensed under the GNU LGPL.
*/
#include <WinSock2.h>
#include <uade/uadeipc.h>
#include <uade/unixatomic.h>
#include <uade/ossupport.h>
#include <Windows.h>
#include <io.h>
#include <assert.h>
#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include "stringcvt.h"


int uade_filesize(size_t *size, const char *pathname)
{
	struct _stat st;
	wchar_t wchr_pathname[4096];
	CtoW(pathname, wchr_pathname);
	if (_wstat(wchr_pathname, &st))
		return -1;
	if (size)
		*size = st.st_size;
	return 0;
}

static int uade_amiga_scandir(char *real, char *dirname, char *fake, int ml)
{
	HANDLE hFile;
	WIN32_FIND_DATA pNextInfo;
	BOOL found = 0;
	wchar_t pattern[8192];
	wchar_t wchr_dirname[4096];
	wchar_t wchr_separator[4096];
	size_t len = strlen(dirname);
	char* separator = len > 0 && (dirname[len - 1] == '/' || dirname[len - 1] == '\\') ? "" : "\\";
	CtoW(dirname, wchr_dirname);
	CtoW(separator, wchr_separator);
	swprintf_s(pattern, _countof(pattern), L"%ls%ls*", wchr_dirname, wchr_separator);
	hFile = FindFirstFileW(pattern, &pNextInfo);
	if (hFile == INVALID_HANDLE_VALUE) {
		uade_warning("Can't open dir (%s) (amiga scandir)\n", dirname);
		return 0;
	}
	do {
		char chr_fileName[8192];
		WtoC(pNextInfo.cFileName, chr_fileName);
		if (!strcmp(fake, chr_fileName)) {
			if (((int)strlcpy(real, chr_fileName, ml)) >= ml) {
				
				uade_warning("uade: %s does not fit real",
					chr_fileName);
				FindClose(hFile);
				return 0;
			}
			found = 1;
			break;
		}
	} while (FindNextFileW(hFile, &pNextInfo));
	if (found) {
		FindClose(hFile);
		return 1;
	}
	FindClose(hFile);
	hFile = FindFirstFileW(pattern, &pNextInfo);

	do {
		char chr_fileName[4096];
		WtoC(pNextInfo.cFileName, chr_fileName);
		if (!_stricmp(fake, chr_fileName)) {
			if (((int)strlcpy(real, chr_fileName, ml)) >= ml) {
				fprintf(stderr, "uade: %s does not fit real", chr_fileName);
				FindClose(hFile);
				return 0;
			}
			found = 1;
			break;
		}
	} while (FindNextFileW(hFile, &pNextInfo));
	FindClose(hFile);
	return found;
}

char* win_dirname(char* dir) {
	char* backslash = strrchr(dir, '\\');
	char* slash = strrchr(dir, '/');
	char* endptr = backslash;

	if (slash != NULL && (endptr == NULL || slash > backslash)) endptr = slash;
	if (dir[0] == '\0' || endptr == NULL) return ".";
	if (endptr == dir || (endptr == dir + 2 && dir[1] == ':')) {
		*(endptr + 1) = '\0';
	}
	else {
		*endptr = '\0';
	}
	return dir;
}

char* uade_dirname(char* dst, char* src, size_t maxlen)
{
	char* srctemp = _strdup(src);

	if (srctemp == NULL)
		return NULL;
	strlcpy(dst, win_dirname(srctemp), maxlen);
	free(srctemp);
	return dst;
}




/* Find file in amiga namespace */
int uade_find_amiga_file(char* realname, size_t maxlen, const char* aname,
	const char* playerdir, const char* moduledir)
{
	char* separator;
	char* ptr;
	char copy[4096];
	char dirname[4096];
	char fake[4096];
	char real[4096];
	int len;
	FILE* file;
	size_t strip_offset;

	if (strlcpy(copy, aname, sizeof(copy)) >= sizeof(copy)) {
		uade_warning("error: amiga tried to open a very long "
			"filename.\nPlease REPORT THIS!\n");
		return -1;
	}
	ptr = copy;
	if (isalpha((unsigned char)ptr[0]) && ptr[1]==':' &&
		(ptr[2]=='\\' || ptr[2]=='/')) {
		if (strlcpy(dirname, ptr, sizeof(dirname)) >= sizeof(dirname)) return -1;
		goto read;
	}
	if ((separator = strchr(ptr, (int)':'))) {
		len = (int)(separator - ptr);
		memcpy(dirname, ptr, len);
		dirname[len] = 0;
		
		if (!_stricmp(dirname, "ENV")) {
			snprintf(dirname, sizeof(dirname), "%s/ENV/", playerdir);
		}
		else if (!_stricmp(dirname, "S")) {
			snprintf(dirname, sizeof(dirname), "%s/S/", playerdir);
		}
		else if (!_stricmp(dirname, "Instruments") && moduledir != NULL) {
			// ScottJohnston player loads samples from Instruments: volume
			snprintf(dirname, sizeof(dirname), "%s/instruments/", moduledir);
		}
		else {
			uade_warning("open_amiga_file: unknown amiga volume "
				"(%s)\n", aname);
			return -1;
		}
		wchar_t wchr_dirname[4096];
		CtoW(dirname, wchr_dirname);
		DWORD attr = GetFileAttributesW(wchr_dirname);
		if (attr==INVALID_FILE_ATTRIBUTES || !(attr & FILE_ATTRIBUTE_DIRECTORY)) {
			uade_warning("Can't open dir (%s) (volume parsing)\n",
				     dirname);
			return -1;
		}
		ptr = separator + 1;
	} else {
		if (*ptr == '/') {
			/* absolute path */
			strlcpy(dirname, "/", sizeof(dirname));
			ptr++;
		} else {
			/* relative path */
			char* zm_ptr;
			zm_ptr = strstr(moduledir, "Zoundmonitor");
			if (!zm_ptr) {
				strlcpy(dirname, moduledir, sizeof(dirname));
				strlcat(dirname, "\\", sizeof(dirname));
			}
			else {
				zm_ptr += strlen("Zoundmonitor");
				zm_ptr++;
				*zm_ptr = '\0';
				strlcpy(dirname, moduledir, sizeof(dirname));
			}
		}
	}

	while ((separator = strchr(ptr, (int) '/'))) {
		len = (int) (separator - ptr);
		if (!len) {
			ptr++;
			continue;
		}
		memcpy(fake, ptr, len);
		fake[len] = 0;
		if (uade_amiga_scandir(real, dirname, fake, sizeof(real))) {
			/* found matching entry */
			if (strlcat(dirname, real, sizeof(dirname)) >= sizeof(dirname)) {
				uade_warning("Too long dir path (%s + %s)\n",
					     dirname, real);
				return -1;
			}
			if (strlcat(dirname, "/", sizeof(dirname)) >= sizeof(dirname)) {
				uade_warning("Too long dir path (%s + %s)\n",
					     dirname, "/");
				return -1;
			}
		} else {
			/* didn't find entry */
			return -1;
		}
		ptr = separator + 1;
	}

	wchar_t wchr_dirname[4096];
	CtoW(dirname, wchr_dirname);
	DWORD attr = GetFileAttributesW(wchr_dirname);
	if (attr == INVALID_FILE_ATTRIBUTES || !(attr & FILE_ATTRIBUTE_DIRECTORY)) {
		uade_warning("Can't open dir (%s) after scanning\n", dirname);
		return -1;
	}

	if (uade_amiga_scandir(real, dirname, ptr, sizeof(real))) {
		/* found matching entry */
		if (strlcat(dirname, real, sizeof(dirname)) >= sizeof(dirname)) {
			uade_warning("Too long dir path (%s + %s)\n",
				     dirname, real);
			return -1;
		}
	} else {
		/* didn't find entry */
		return -1;
	}
read:
	CtoW(dirname, wchr_dirname);
	file = _wfopen(wchr_dirname, L"rb");
	if (file == NULL) {
		uade_warning("Couldn't open file (%s) induced by (%s)\n",
			     dirname, aname);
		return -1;
	}
	fclose(file);

	/* Strip leading "./" from the real path name when copying */
	strip_offset = (strncmp(dirname, "./", 2) == 0) ? 2 : 0;

	strlcpy(realname, dirname + strip_offset, maxlen);

	return 0;
}

void uade_arch_kill_and_wait_uadecore(struct uade_ipc *ipc, HANDLE *uade_process)
{
	if (*uade_process == NULL) return;

	uade_atomic_close(ipc->in_fd);
	uade_atomic_close(ipc->out_fd);

	/*
	 * Wait until one of two happens:
	 * 1. uadepid is successfully handled (waitpid() returns uadepid)
	 * 2. someone else has processed uadepid (waitpid() returns -1)
	 */
	DWORD result = WaitForSingleObject(*uade_process, 1000);
	if (result == WAIT_TIMEOUT) {
		if (!TerminateProcess(*uade_process, 1)) {
			uade_warning("TerminateProcess failed: %lu\n", GetLastError());
		}
		else {
			result = WaitForSingleObject(*uade_process, 1000);
			if (result == WAIT_TIMEOUT) {
				uade_warning("uadecore remained active after terminating\n");
			}
			else if (result == WAIT_FAILED) {
				uade_warning("waiting foe terminated uadecore failed: %lu/n", GetLastError());
			}
		}
	}
	else if (result == WAIT_FAILED) {
		uade_warning("waiting foe uadecore failed: %lu/n", GetLastError());
	}
	CloseHandle(*uade_process);

	*uade_process = NULL;
}

int uade_arch_spawn(struct uade_ipc *ipc, HANDLE *uade_process, const char *uadename,
		    const int *keep_fds)
{
	SECURITY_ATTRIBUTES sa;
	ZeroMemory(&sa, sizeof(sa));
	sa.nLength = sizeof(sa);
	sa.bInheritHandle = TRUE;
	sa.lpSecurityDescriptor = NULL;

	HANDLE core_read, core_write, parent_read, parent_write;

	//parent->uade_core
	BOOL ret1 = CreatePipe(&core_read, &parent_write, &sa, 0);
	if (!ret1) {
		uade_warning("Can not create parent->uade_core pipe: %lu\n", GetLastError());
		return -1;
	}
	//uade_core->parent
	BOOL ret2 = CreatePipe(&parent_read, &core_write, &sa, 0);
	if (!ret2) {
		CloseHandle(core_read);
		CloseHandle(parent_write);
		uade_warning("Can not create uade_core->parent pipe: %lu\n", GetLastError());
		return -1;
	}
	if (!(SetHandleInformation(parent_write, HANDLE_FLAG_INHERIT, 0) 
		& SetHandleInformation(parent_read, HANDLE_FLAG_INHERIT, 0))) {
		uade_warning("Can not deinherit parent handle: %lu\n", GetLastError());
		return -1;
	}
	

	STARTUPINFOEX si;
	PROCESS_INFORMATION pi;
	SIZE_T attr_size = 0;
	HANDLE inherit_handles[2];
	inherit_handles[0] = core_read;
	inherit_handles[1] = core_write;
	ZeroMemory(&si, sizeof(si));
	si.StartupInfo.cb = sizeof(si);
	ZeroMemory(&pi, sizeof(pi));
	InitializeProcThreadAttributeList(NULL, 1, 0, &attr_size);
	si.lpAttributeList = HeapAlloc(GetProcessHeap(), 0, attr_size);
	if (si.lpAttributeList == NULL) {
		CloseHandle(core_read);
		CloseHandle(core_write);
		CloseHandle(parent_read);
		CloseHandle(parent_write);
		uade_warning("Attribute list creation FAILED: %lu", GetLastError());
		return -1;
	}
	BOOL AL_RET = InitializeProcThreadAttributeList(si.lpAttributeList, 1, 0, &attr_size);
	if (!AL_RET) {
		CloseHandle(core_read);
		CloseHandle(core_write);
		CloseHandle(parent_write);
		CloseHandle(parent_read);
		HeapFree(GetProcessHeap(), 0, si.lpAttributeList);
		uade_warning("Attribute list creation FAILED: %lu", GetLastError());
		return -1;
	}
	BOOL UPAL_RET = UpdateProcThreadAttribute(si.lpAttributeList, 0, PROC_THREAD_ATTRIBUTE_HANDLE_LIST, inherit_handles, sizeof(inherit_handles), NULL, NULL);
	if (!UPAL_RET) {
		CloseHandle(core_read);
		CloseHandle(core_write);
		CloseHandle(parent_write);
		CloseHandle(parent_read);
		DeleteProcThreadAttributeList(si.lpAttributeList);
		HeapFree(GetProcessHeap(), 0, si.lpAttributeList);
		uade_warning("Attribute list filling FAILED: %lu", GetLastError());
		return -1;
	}
	DWORD creation_flags = EXTENDED_STARTUPINFO_PRESENT | CREATE_NO_WINDOW;
	wchar_t command[512] = { 0 };
	wchar_t wchr_uadename[2048] = { 0 };
	CtoW(uadename, wchr_uadename);
	swprintf_s(command, _countof(command), L"\"%ls\" -i %llu -o %llu", wchr_uadename,(unsigned long long)(uintptr_t)core_read, (unsigned long long)(uintptr_t)core_write);
	BOOL RET = CreateProcessW(NULL, command, NULL, NULL, TRUE, creation_flags, NULL, NULL, &si.StartupInfo, &pi);
	if (!RET) {
		uade_warning("CreateProcess FAILED: %lu\n", GetLastError());
		CloseHandle(core_read);
		CloseHandle(core_write);
		CloseHandle(parent_write);
		CloseHandle(parent_read);
		DeleteProcThreadAttributeList(si.lpAttributeList);
		HeapFree(GetProcessHeap(), 0, si.lpAttributeList);
		si.lpAttributeList = NULL;
		return -1;
	}
	DeleteProcThreadAttributeList(si.lpAttributeList);
	HeapFree(GetProcessHeap(), 0, si.lpAttributeList);
	si.lpAttributeList = NULL;
	CloseHandle(core_read);
	CloseHandle(core_write);
	CloseHandle(pi.hThread);

	int parent_write_fd = _open_osfhandle((intptr_t)parent_write, _O_BINARY);
	if (parent_write_fd == -1) {
		CloseHandle(parent_write);
		CloseHandle(parent_read);
		uade_warning("handle to fd FAILED: %lu", GetLastError());
		return -1;
	}
	int parent_read_fd = _open_osfhandle((intptr_t)parent_read, _O_BINARY);
	if (parent_read_fd == -1) {
		_close(parent_write_fd);
		CloseHandle(parent_read);
		uade_warning("handle to fd FAILED: %lu", GetLastError());
		return -1;
	}
	
	uade_set_peer(ipc, 1, parent_read_fd, parent_write_fd);
	*uade_process = pi.hProcess;
	return 0;
}
