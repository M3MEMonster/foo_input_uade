#include "stdafx.h"
#include <uade/uade.h>
#include <string>
#include <string_view>
#include <atomic>
#include <vector>
#include <filesystem>
#include "database_init.h"
#include "songlengths.h"
#include "metadata.h"
#include "global_config.h"
#include "GUID.h"
#include "support_format.h"

constexpr unsigned channel = 2U;

class input_uade : public input_stubs {
public:
	service_ptr_t<file> m_file;
	struct uade_state* m_state;
	struct uade_config* m_config;
	pfc::string8 m_path;
	pfc::array_t<uint8_t> m_file_buf;
	file_mapped* m_songlength_database;
	file_mapped* m_metadata_database;
	bool is_decode_initialized = false;
	uint64_t m_produced_sample;
	uint64_t m_total_sample;
	unsigned m_samplerate;
	bool first_block;
#ifdef _DEBUG
	bool first_time = true;
#endif
	std::wstring m_song_name = L"";
	std::wstring m_codec = L"";
	int m_min_subsong;
	
public:
	input_uade() : m_state(nullptr), m_config(nullptr) {}
	~input_uade() {
		if (m_state != nullptr) {
			uade_cleanup_state(m_state);
			m_state = nullptr;
		}
		free(m_config);
		m_config = nullptr;
	}

	template<typename Entry>
	static const Entry* binary_search(Entry* entry, const std::byte* table_ptr, const std::size_t table_size, const uint64_t target) {
		int64_t left = 0, right = (uint64_t)table_size - 1;
		while (left <= right) {
			int64_t mid = left + (right - left) / 2;
			memcpy(entry, table_ptr + (mid * sizeof(Entry)), sizeof(Entry));
			int64_t comp_ret = entry->md5 - target;
			if (!comp_ret) {
				return entry;
			}
			else if (comp_ret < 0) {
				left = mid + 1;
			}
			else {
				right = mid - 1;
			}

		}
		return nullptr;
	}
	static struct uade_file* fb2k_amiga_loader(const char* name, const char* playerdir, void* context, struct uade_state* state) {
		auto* self = static_cast<input_uade*>(context);
		try {
			service_ptr_t<file> file;
			char* pos = const_cast<char*>(strstr(name, "file://"));
			if (pos) {
				pos += strlen("file://");
				for (int i = 0; *pos != '\0'; pos++) {
					if (*pos == '/') *pos = '\\';
				}
			}

			filesystem::g_open_read(file, name, fb2k::noAbort);
			pfc::array_t<uint8_t> data;
			file->read_till_eof(data, fb2k::noAbort);
			return uade_file(name, data.get_ptr(), data.get_size());
		}
		catch (...) {
			return nullptr;
		}
	}
	void create_uade_state() {
		m_state = uade_new_state(m_config);
		if (m_state) uade_set_amiga_loader(&fb2k_amiga_loader, this, m_state);
	}

	void open(service_ptr_t<file> p_filehint, const char* p_path, t_input_open_reason p_reason, abort_callback& p_abort) {
		if (p_reason == input_open_info_write) throw exception_tagging_unsupported();//our input does not support retagging.
		m_file = p_filehint;//p_filehint may be null, hence next line
		input_open_file_helper(m_file, p_path, p_reason, p_abort);//if m_file is null, opens file with appropriate privileges for our operation (read/write for writing tags, read-only otherwise).
		m_path = p_path;
		m_file->read_till_eof(m_file_buf, fb2k::noAbort);
		m_config = uade_new_config();
		std::wstring filename = std::filesystem::u8path(p_path).filename().wstring();
		const size_t dot = filename.find(L'.');
		const std::wstring prefix = filename.substr(0, dot);
		CharLowerBuffW(const_cast<LPWSTR>(prefix.c_str()), static_cast<DWORD>(prefix.size()));
		const std::wstring suffix = filename.substr(dot + 1);
		CharLowerBuffW(const_cast<LPWSTR>(suffix.c_str()), static_cast<DWORD>(suffix.size()));
		if (support_formats_in_amiga_type.find(prefix) != support_formats_in_amiga_type.end()) {
			m_codec = support_formats_in_amiga_type[prefix];
			m_song_name = suffix;
		}
		else if (support_formats_in_win_type.find(suffix) != support_formats_in_win_type.end()) {
			const size_t zm = std::filesystem::u8path(p_path).wstring().find(L"Zoundmonitor");
			if (zm == std::wstring::npos && suffix == L"sng") {
				m_codec = support_formats_in_win_type[L"rjp"];
			}
			else {
				m_codec = support_formats_in_win_type[suffix];
			}
			
		}
		
		std::filesystem::path dll_path(core_api::get_my_full_path());
		std::filesystem::path base_dir = dll_path.parent_path();
		std::filesystem::path uade_base_dir = base_dir / "uade";
		std::filesystem::path uadecore_dir = base_dir / "win_ade_core.exe";
		std::filesystem::path database_dir = uade_base_dir / "database";
		static file_mapped SonglengthDatabase(database_dir / "songlengths.bin");
		static file_mapped MetadataDatabasde(database_dir / "metadata.bin");
		m_songlength_database = &SonglengthDatabase;
		m_metadata_database = &MetadataDatabasde;
	#ifdef _DEBUG
		FILE* output = nullptr;
		//pfc::string8 dbg_path = core_api::pathInProfile("uade-debug.log");
		freopen_s(&output, R"(D:\uade-debug.log)", "a", stderr);
		uade_config_set_option(m_config, UC_VERBOSE, NULL);
	#endif
		uade_config_set_option(m_config, UC_BASE_DIR, uade_base_dir.string().c_str());
		uade_config_set_option(m_config, UC_UADECORE_FILE, uadecore_dir.string().c_str());
		uade_config_set_option(m_config, UC_NO_CONTENT_DB, NULL);
		uade_config_set_option(m_config, UC_ONE_SUBSONG, NULL);
		uade_config_set_option(m_config, UC_FREQUENCY, sample_rate_table[(int)cfg_uade_samplerate]);
		uade_config_set_option(m_config, UC_FILTER_TYPE, filter_table[(int)cfg_uade_filter]);
		uade_config_set_option(m_config, UC_RESAMPLER, resampler_table[(int)cfg_uade_resampler]);
		
		if (cfg_uade_clock == CLOCK::PAL) {
			uade_config_set_option(m_config, UC_PAL, NULL);
		}
		else if (cfg_uade_clock == CLOCK::NTSC) {
			uade_config_set_option(m_config, UC_NTSC, NULL);
		}
		pfc::string8 mute_mask="\0";
		if ((bool)cfg_uade_mute1) mute_mask << "0";
		if ((bool)cfg_uade_mute2) mute_mask << "1";
		if ((bool)cfg_uade_mute3) mute_mask << "2";
		if ((bool)cfg_uade_mute4) mute_mask << "3";
		uade_config_set_option(m_config, UC_MUTEMASK, mute_mask.c_str());
		if ((bool)cfg_uade_indef_play) uade_config_set_option(m_config, UC_DISABLE_TIMEOUTS, NULL);
		char gain_char[64];
		snprintf(gain_char, sizeof(gain_char), "%.2f", (double)cfg_uade_gain);
		if ((bool)cfg_uade_enable_gain) uade_config_set_option(m_config, UC_GAIN, gain_char);
		if ((bool)cfg_uade_headphone) uade_config_set_option(m_config, UC_HEADPHONES, NULL);
		if ((bool)cfg_uade_headphone2) uade_config_set_option(m_config, UC_HEADPHONES2, NULL);
		if ((bool)cfg_uade_ignore_player_check) uade_config_set_option(m_config, UC_IGNORE_PLAYER_CHECK, NULL);
		char pan_char[64];
		snprintf(pan_char, sizeof(pan_char), "%.1f", (double)cfg_uade_pan);
		uade_config_set_option(m_config, UC_PANNING_VALUE, pan_char);

		m_samplerate = std::stoi(sample_rate_table[(int)cfg_uade_samplerate]);
		create_uade_state();
	}

	void get_info(t_uint32 p_subsong, file_info& p_info, abort_callback& p_abort) {
		const struct uade_song_info* song_info;
		int play_ret;
		if (!is_decode_initialized) {
			play_ret = uade_play_from_buffer(m_path.c_str(), m_file_buf.get_ptr(), m_file_buf.get_size(), p_subsong, m_state);
		}
		else {
			play_ret = 1;
		}
		
		if (play_ret == 1) {
			
			song_info = uade_get_song_info(m_state);
			std::string md5_hex48_str(song_info->modulemd5, 12);
		#ifdef _DEBUG
			if (first_time) {
				console::printf("[UADE Input] md5=%s", md5_hex48_str.c_str());
				first_time = false;
			}
		#endif
			const uint64_t md5_hex48 = std::stoull(md5_hex48_str, nullptr, 16);
			songlength_header SL_HEADER;
			memcpy(&SL_HEADER, m_songlength_database->data(), sizeof(songlength_header));
			SonglengthEntry SL_entry;
			const SonglengthEntry* duration_entry = binary_search<SonglengthEntry>(&SL_entry, m_songlength_database->data() + sizeof(songlength_header), SL_HEADER.entry_count, md5_hex48);
			double duration = 0;
			if (song_info->duration) {
				duration = song_info->duration;
			}
			else if (duration_entry && p_subsong + 1 - duration_entry->min_subsong <= duration_entry->subsong_count)  {
				duration = *(uint32_t*)(m_songlength_database->data() + SL_HEADER.duration_table_start + (duration_entry->offset + p_subsong - duration_entry->min_subsong) * sizeof(uint32_t)) / 1000.0;
				if (!duration) duration = 0.1;
			}
			else {
				duration = (double)cfg_uade_default_length;
			}
			p_info.set_length(duration);
			m_total_sample = static_cast<uint64_t>(duration * m_samplerate) * channel * sizeof(uint16_t);
			metadata_header MA_HEADER;
			memcpy(&MA_HEADER, m_metadata_database->data(), sizeof(metadata_header));
			MetadataEntry MA_entry;
			const MetadataEntry* metadata_entry = binary_search<MetadataEntry>(&MA_entry, m_metadata_database->data() + sizeof(metadata_header), MA_HEADER.entry_count, md5_hex48);
			if (metadata_entry) {
				std::string metadata_str((char*)(m_metadata_database->data() + MA_HEADER.string_table_start + metadata_entry->offset), metadata_entry->str_length);
				const char* fields[] = { "artist","publisher","album","date" };
				std::string_view remaining(metadata_str.c_str(), metadata_entry->str_length);
				for (const char* field : fields) {
					const size_t end = remaining.find('\0');
					const std::string value(remaining.substr(0, end));
					if (!value.empty()) p_info.meta_add(field, value.c_str());
					remaining.remove_prefix(end + 1);
				}
			}
			if (!m_song_name.empty()) {
				p_info.meta_add("title", pfc::stringcvt::string_utf8_from_wide(m_song_name.c_str()).get_ptr());
			}
			
			p_info.info_set_int("channels", channel);
			p_info.info_set_int("bitspersample", 16);
			p_info.info_set("encoding", "synthesized");
			p_info.info_set("codec", pfc::stringcvt::string_utf8_from_wide(m_codec.c_str()).get_ptr());
		}
		else if (play_ret == 0) {
			throw exception_io_data();
		}
		else {
			uade_cleanup_state(m_state);
			create_uade_state();
			throw exception_aborted();
		}
		if (!is_decode_initialized) {
			int stop_ret = uade_stop(m_state);
			if (stop_ret == -1) {
				uade_cleanup_state(m_state);
				create_uade_state();
				throw exception_aborted();
			}
		}
		
	}

	t_filestats2 get_stats2(unsigned f, abort_callback& a) { return m_file->get_stats2_(f, a); }
	t_filestats get_file_stats(abort_callback& p_abort) { return m_file->get_stats(p_abort); }

	
	unsigned get_subsong_count() {
		const struct uade_song_info* song_info;
		int play_ret = uade_play_from_buffer(m_path.c_str(), m_file_buf.get_ptr(), m_file_buf.get_size(), -1, m_state);
		if (play_ret == 1) {
			song_info = uade_get_song_info(m_state);
		}
		else if (play_ret == 0) {
			throw exception_io_data();
		}
		else {
			uade_cleanup_state(m_state);
			create_uade_state();
			throw exception_aborted();
		}
		int subsong_count = song_info->subsongs.max - song_info->subsongs.min + 1;
		m_min_subsong = song_info->subsongs.min;
		int stop_ret = uade_stop(m_state);
		if (stop_ret == -1) {
			uade_cleanup_state(m_state);
			create_uade_state();
			throw exception_aborted();
		}
		return subsong_count;
	}

	t_uint32 get_subsong(unsigned p_index) {
		return m_min_subsong + p_index;
	}

	void decode_initialize(t_uint32 p_subsong, unsigned p_flags, abort_callback& p_abort) {
		m_produced_sample = 0;
		first_block = true;
		int play_ret = uade_play_from_buffer(m_path.c_str(), m_file_buf.get_ptr(), m_file_buf.get_size(), p_subsong, m_state);
		if (play_ret == 0) {
			throw exception_io_data();
		}
		else if (play_ret == -1) {
			uade_cleanup_state(m_state);
			create_uade_state();
			throw exception_aborted();
		}
		is_decode_initialized = true;
	}

	bool decode_run(audio_chunk& p_chunk, abort_callback& p_abort) {
		ssize_t read_ret{ 0 };
		enum { chunk_size = 1024 };
		std::vector<uint16_t> buffer(chunk_size * 2, 0);
		while ((read_ret=uade_read(buffer.data(), buffer.size() * sizeof(buffer[0]), m_state)) 
			&& read_ret != -1 && m_produced_sample < m_total_sample) {
			p_chunk.set_data_fixedpoint(buffer.data(), read_ret, m_samplerate, channel, 16, audio_chunk::g_guess_channel_config(2));
			if(!(bool)cfg_uade_indef_play) m_produced_sample += read_ret;
			return true;
		}
		if (read_ret == -1) {
			throw exception_aborted();
		}

		return false;
	}

	void decode_seek(double p_seconds, abort_callback& p_abort) {
		first_block = true;
		m_produced_sample = static_cast<uint64_t>(p_seconds * m_samplerate) * channel * sizeof(uint16_t);
		int seek_ret = uade_seek(UADE_SEEK_SONG_RELATIVE, p_seconds, -1, m_state);
		if (seek_ret == -1) throw exception_aborted();
	}
	bool decode_can_seek() { return true; }
	bool decode_get_dynamic_info(file_info& p_out, double& p_timestamp_delta) {
		if (first_block) {
			p_out.info_set_int("samplerate", m_samplerate);
			first_block = false;
			return true;
		}
		else {
			return false;
		}
	}
	bool decode_get_dynamic_info_track(file_info& p_out, double& p_timestamp_delta) { return false; } // deals with dynamic information such as track changes in live streams
	void decode_on_idle(abort_callback& p_abort) { m_file->on_idle(p_abort); }

	// Note that open() already rejects requests to open for tag writing, so these should never get called.
	void retag_set_info(t_uint32 p_subsong, const file_info& p_info, abort_callback& p_abort) { throw exception_tagging_unsupported(); }
	void retag_commit(abort_callback& p_abort) { throw exception_tagging_unsupported(); }
	void remove_tags(abort_callback&) { throw exception_tagging_unsupported(); }

	static bool g_is_our_content_type(const char* p_content_type) { return false; } // match against supported mime types here
	static bool g_is_our_path(const char* p_path, const char* p_extension) {
		std::wstring filename = std::filesystem::u8path(p_path).filename().wstring();
		std::wstring w_extension(pfc::stringcvt::string_wide_from_utf8(p_extension).get_ptr());
		CharLowerBuffW(const_cast<LPWSTR>(w_extension.c_str()), static_cast<DWORD>(w_extension.size()));
		if (support_formats_in_win_type.find(w_extension) != support_formats_in_win_type.end()) return true;
		const size_t dot = filename.find(L'.');
		if (dot == std::wstring::npos || dot == filename.size()) return false;
		const std::wstring amiga_format = filename.substr(0, dot);
		CharLowerBuffW(const_cast<LPWSTR>(amiga_format.c_str()), static_cast<DWORD>(amiga_format.size()));
		if (support_formats_in_amiga_type.find(amiga_format) != support_formats_in_amiga_type.end()) return true;
		return false;
	}
	static const char* g_get_name() { return "UADE Input"; }
	static const GUID g_get_guid() { return guid_decoder; }
};

static input_factory_t<input_uade> g_input_uade_factory;
