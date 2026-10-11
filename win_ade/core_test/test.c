#include <stdio.h>
#include <stdlib.h>
#include <io.h>
#include <fcntl.h>
#include <Windows.h>
#include <uade/uadeipc.h>


int main() {
	int to_core[2] = { 0 };
	unsigned char inbuf[8] = {1,3,4,6,6,4,3,9};
	unsigned char outbuf[8] = { 0 };

	SECURITY_ATTRIBUTES sa;
	ZeroMemory(&sa, sizeof(sa));
	sa.nLength = sizeof(sa);
	sa.bInheritHandle = TRUE;
	sa.lpSecurityDescriptor = NULL;

	HANDLE core_read, core_write;
	HANDLE parent_read, parent_write;

	//parent->uade_core
	BOOL ret1 = CreatePipe(&core_read, &parent_write, &sa, 0);
	if (!ret1) {
		printf("CreatePipe FAILED: %lu.\n", GetLastError());
		return -1;
	}
	//uade_core->parent
	BOOL ret2 = CreatePipe(&parent_read, &core_write, &sa, 0);
	if (!ret2) {
		printf("CreatePipe FAILED: %lu.\n", GetLastError());
		return -1;
	}
	SetHandleInformation(parent_write, HANDLE_FLAG_INHERIT, 0);
	SetHandleInformation(parent_read, HANDLE_FLAG_INHERIT, 0);
	
	wchar_t command[512] = { 0 };
	swprintf_s(command, _countof(command), L".\\win_ade_core.exe -i %llu -o %llu", (unsigned long long)(uintptr_t)core_read, (unsigned long long)(uintptr_t)core_write);

	STARTUPINFO si;
	PROCESS_INFORMATION pi;
	ZeroMemory(&si, sizeof(si));
	si.cb = sizeof(si);
	ZeroMemory(&pi, sizeof(pi));
	BOOL RET = CreateProcess(NULL, command, NULL, NULL, TRUE, 0, NULL, NULL, &si, &pi);
	if (!RET) {
		printf("CreateProcess FAILED: %lu.\n", GetLastError());
		return -1;
	}
	CloseHandle(core_read);
	CloseHandle(core_write);
	CloseHandle(pi.hThread);
	int parent_write_fd = _open_osfhandle((intptr_t)parent_write, _O_BINARY);
	int parent_read_fd = _open_osfhandle((intptr_t)parent_read, _O_BINARY);

	struct uade_ipc ipc;
	uade_set_peer(&ipc, 1, parent_write_fd, parent_read_fd);
	int result = uade_send_string(UADE_COMMAND_CONFIG, ".\\config.conf", &ipc);
	if (result < 0) {
		printf("CFG send FAILED");
	}
	else {
		printf("CFG send SUCCEED");
	}
	
	
	return 0;
}