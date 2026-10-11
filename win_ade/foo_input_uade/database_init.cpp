#include "database_init.h"
#include <filesystem>
file_mapped::file_mapped(const std::filesystem::path& path) {
	m_file = CreateFileW(path.wstring().c_str(), GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_DELETE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if (m_file == INVALID_HANDLE_VALUE) throw std::runtime_error("Cannot open database");
	LARGE_INTEGER size{};
	if (!GetFileSizeEx(m_file, &size) || size.QuadPart <= 0) throw std::runtime_error("Invalid database size");
	m_size = static_cast<std::size_t>(size.QuadPart);
	m_mapping = CreateFileMappingW(m_file, NULL, PAGE_READONLY, 0, 0, NULL);
	if (m_mapping == nullptr) throw std::runtime_error("Cannot create file mapping");
	m_data = static_cast<const std::byte*>(MapViewOfFile(m_mapping, FILE_MAP_READ, 0, 0, 0));
}
file_mapped::~file_mapped() {
	if (m_data != nullptr) UnmapViewOfFile(m_data);
	if (m_mapping != nullptr) CloseHandle(m_mapping);
	if (m_file != INVALID_HANDLE_VALUE) CloseHandle(m_file);
}
const std::byte* file_mapped::data() const {
	return m_data;
}

std::size_t file_mapped::size() const {
	return m_size;
}