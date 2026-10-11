#ifndef _UADE_WRITE_AUDIO_MAIN_H_
#define _UADE_WRITE_AUDIO_MAIN_H_

#include <cstdint>
#include <deque>
#include <map>
#include <string>
#include <vector>

extern "C" {
#include "../src/include/write_audio_ext.h"
}

namespace uade {
namespace write_audio {
namespace main {

extern unsigned int SCREEN_WIDTH;
extern unsigned int SCREEN_HEIGHT;
extern bool VIDEO_OUTPUT;

class Settings {
public:
	Settings() {}

	int aa_factor = 4;
	std::string csv_path;
	bool debug_audio_buffering = false;
	uint32_t fps = 60;
	bool fullscreen = false;
	int sample_rate = 44100;  // FIX: hardcoded into wav
	float panning = 0.7;
	std::string wave_path;
};

extern size_t NORMALIZATION_LENGTH;

class Normalizator {
public:
	Normalizator(size_t length);
	void add_values(const std::vector<float> &values);
	float get_normalizer() const;

	size_t length_;
	std::deque<float> data_;
};

class Channel {
public:
	Channel();

	void advance_time(const int tdelta);

	void poll_time_window(
		std::vector<int16_t> *returned_time_window,
		std::vector<uint16_t> *returned_meta_window);

	int16_t value;  // AUDxDAT * AUDxVOL. Range: [-128 * 64, 127 * 64]
	int len_;
	int per_;
	uint32_t lc_;
	uint16_t buffer_nr_;
	std::vector<int16_t> time_window_;
	std::vector<uint16_t> meta_window_;
	std::vector<float> previous_frame_signal_;
};

class AudioChannels {
public:
	AudioChannels(unsigned normalization_length) :
		normalizator(normalization_length) 
	{
	}

	Channel channels_[4];
	int outputs_[2];
	std::map<uint32_t, uint16_t> address_to_buffer_nr_;
	Normalizator normalizator;
};

bool advance_time(AudioChannels *audio_channels,
		  uint32_t tdelta,
		  std::vector<uint32_t> *framebuffer,
		  const std::vector<uint32_t> &colors,
		  const int aa_factor,
		  std::vector<uint32_t> *aa_framebuffer,
		  FILE *csv_file,
		  int frame_number);

void handle_paula_channel_output(AudioChannels *channels,
				 const struct uade_write_audio_frame &frame);

void handle_paula_event(AudioChannels *channels,
			FILE *wave_file,
			const struct uade_write_audio_frame &frame,
			const Settings &settings,
			std::vector<uint16_t> *accumulated_audio);

}  // namespace main
}  // namespace write_audio
}  // namespace uade

#endif
