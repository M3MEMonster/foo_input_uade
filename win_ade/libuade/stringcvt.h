#pragma once
#include <windows.h>

static void CtoW(char* src_char, wchar_t* wchar_buf) {
	int wchar_length = MultiByteToWideChar(CP_UTF8, 0, src_char, -1, NULL, 0);
	MultiByteToWideChar(CP_UTF8, 0, src_char, -1, wchar_buf, wchar_length);
}

static void WtoC(wchar_t* src_wchar, char* char_buf) {
	int char_length = WideCharToMultiByte(CP_UTF8, 0, src_wchar, -1, NULL, 0, 0, NULL);
	WideCharToMultiByte(CP_UTF8, 0, src_wchar, -1, char_buf, char_length, 0, NULL);
}
