#pragma once

#include <windows.h>
#include <cstddef>
#include <filesystem>

class file_mapped {
private:
	HANDLE m_file = INVALID_HANDLE_VALUE;
	HANDLE m_mapping = nullptr;
	const std::byte* m_data = nullptr;
	std::size_t m_size = 0;
public:
	explicit file_mapped(const std::filesystem::path& path);
	~file_mapped();
	const std::byte* data() const;
	std::size_t size() const;
	//NO COPY
	file_mapped(const file_mapped&) = delete;
	file_mapped& operator=(const file_mapped&) = delete;

};
