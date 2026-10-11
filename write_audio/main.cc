#include <algorithm>
#include <arpa/inet.h>
#include <cassert>
#include <cstdio>
#include <cmath>
#include <cstring>
#include <errno.h>
#ifdef __APPLE__
#include "macos_endian.h"
#else
#include <endian.h>
#endif
#include <iostream>
#include <map>
#include <math.h>
#include <signal.h>
#include <string>
#include <vector>

#include "common.h"
#include "main.h"
#include "uadegl.h"
#include "sdl_mode.h"

using std::map;
using std::string;
using std::vector;

using uade::write_audio::main::AudioChannels;
using uade::write_audio::main::Channel;
using uade::write_audio::main::Settings;
using uade::write_audio::main::SCREEN_WIDTH;
using uade::write_audio::main::VIDEO_OUTPUT;

using uade::write_audio::uadegl::draw_line;
using uade::write_audio::uadegl::draw_line_aa;
using uade::write_audio::uadegl::shrink_aa_framebuffer;

using uade::write_audio::sdl_mode::sdl_output;

#define NUM_AMIGA_CHANNELS 4

namespace {

unsigned int HEIGHT_MARGIN = 8;

float LINE_WIDTH = 2.0;  // Only supported when ANTIALIASING is true
bool ANTIALIASING = true;

unsigned int PIXELS_PER_SAMPLE = 2;
const unsigned int SOUNDTICKS_PAL = 3546895;
const unsigned int AMIGA_FRAME_TICKS = SOUNDTICKS_PAL / 50;

// Number of Amiga bus cycles per rendered output video frame.
// Note: the output framerate is often not 50 Hz.
size_t VIDEO_FRAME_TICKS;

unsigned int SAMPLES_PER_FRAME;
unsigned int AMIGA_PIXEL_TICKS;

const float EPSILON = 1e-10;

}  // end of anonymous namespace

namespace uade {
namespace write_audio {
namespace main {

unsigned int SCREEN_WIDTH = 1280;
unsigned int SCREEN_HEIGHT = 720;  // Generate 720p videos by default
bool VIDEO_OUTPUT = true;

size_t NORMALIZATION_LENGTH = 50;


void set_resolution(const unsigned int width, const unsigned int height)
{
	CHECK(width != (unsigned int) -1);
	CHECK(height != (unsigned int) -1);
	CHECK(width > 0 && height > 0);

	SCREEN_WIDTH = width;
	SCREEN_HEIGHT = height;  // Generate 720p videos
	PIXELS_PER_SAMPLE = 2;
	SAMPLES_PER_FRAME = SCREEN_WIDTH / PIXELS_PER_SAMPLE;
	HEIGHT_MARGIN = 8 * height / 720;
	AMIGA_PIXEL_TICKS = AMIGA_FRAME_TICKS / SAMPLES_PER_FRAME;
}

void integrate(vector<float> *signal, vector<uint16_t> *meta,
	       const vector<int16_t> &time_window,
	       const vector<uint16_t> &meta_window)
{
	signal->clear();
	meta->clear();

	// Split time_window into constant size segments, integrate the
	// segments that represent screen pixels, and normalize the integral.
	// The segment size is AMIGA_PIXEL_TICKS.
	size_t i = 0;

	const double multiplier = 1.0 / (AMIGA_PIXEL_TICKS * 64 * 128);

	while (true) {
		const size_t end = i + AMIGA_PIXEL_TICKS;
		if (end > time_window.size())
			break;

		meta->push_back(meta_window[i]);

		int64_t sum = 0;

		for (; i < end; i++)
			sum += time_window[i];

		const double x = sum * multiplier;

		assert(x >= -1.0 and x <= 1.0);
		signal->push_back(x);
	}
}

// Compute sum of squared differences between the previous and the current
// frame. We are searching for a trigger_point value that minimizes the sum.
float evaluate_cut_cost(const vector<float> &signal, const size_t trigger_point,
			const vector<float> &previous_frame_signal)
{
	const size_t CENTERING = SAMPLES_PER_FRAME / 2;
	assert(signal.size() >= (trigger_point + CENTERING));
	assert(previous_frame_signal.size() == SAMPLES_PER_FRAME);
	float sum = 0.0;
	for (size_t i = 0; i < CENTERING; i++) {
		const float delta = signal[trigger_point + i] - (
			previous_frame_signal[CENTERING + i]);
		sum += delta * delta;
	}
	return sum;
}

void trigger(vector<float> *signal,
	     vector<uint16_t> *meta,
	     const vector<float> &previous_frame_signal)
{
	int trigger_state = 0;
	const size_t CENTERING = SAMPLES_PER_FRAME / 2;
	size_t best_cut_point = 0;
	float best_cut_cost = -1.0;

	for (size_t i = CENTERING; i < SAMPLES_PER_FRAME; i++) {
		const float x = (*signal)[i];
		if (trigger_state == 0) {
			if (x < 0.0)
				trigger_state = 1;
		} else if (x >= 0.0) {
			assert(trigger_state == 1);
			if (previous_frame_signal.size() > 0) {
				const float cut_cost = evaluate_cut_cost(
					*signal, i, previous_frame_signal);
				if (best_cut_cost < 0.0 or
				    cut_cost < best_cut_cost) {
					best_cut_cost = cut_cost;
					assert(i >= CENTERING);
					best_cut_point = i - CENTERING;
				}
			}
			trigger_state = 0;
		}
	}

	assert((best_cut_point + SAMPLES_PER_FRAME) <= signal->size());

	*signal = vector<float>(
		signal->begin() + best_cut_point,
		signal->begin() + best_cut_point + SAMPLES_PER_FRAME);

	*meta = vector<uint16_t>(
		meta->begin() + best_cut_point,
		meta->begin() + best_cut_point + SAMPLES_PER_FRAME);

	assert(signal->size() == SAMPLES_PER_FRAME);
	assert(meta->size() == SAMPLES_PER_FRAME);
}

void advance_time_on_channel(
	vector<float> *signal,
	vector<uint16_t> *meta,
	Channel *channel, const int tdelta)
{
	signal->clear();
	meta->clear();

	channel->advance_time(tdelta);

	vector<int16_t> time_window;
	vector<uint16_t> meta_window;

	channel->poll_time_window(&time_window, &meta_window);

	if (time_window.size() > 0) {
		integrate(signal, meta, time_window, meta_window);

		trigger(signal, meta, channel->previous_frame_signal_);

		// Record this frame's signal to be used for triggering
		// in the next frame
		channel->previous_frame_signal_ = *signal;
	}
}

void write_le32(FILE *f, const uint32_t x)
{
	unsigned char buf[4];
	buf[0] = x & 0xff;
	buf[1] = x >> 8;
	buf[2] = x >> 16;
	buf[3] = x >> 24;
	size_t ret = fwrite(buf, 4, 1, f);
	assert(ret == 1);
}

vector<uint32_t> read_colors(int num_colors, const string colors_path)
{
	if (num_colors <= 0) {
		fprintf(stderr, "Invalid number of colors. Was --colors argument given?\n");
		abort();
	}
	if (colors_path.size() == 0) {
		fprintf(stderr, "--colors not given\n");
		abort();
	}
	FILE *colors_file = fopen(colors_path.c_str(), "rb");
	if (colors_file == NULL) {
		fprintf(stderr, "Unable to open colors file %s\n",
			colors_path.c_str());
		abort();
	}
	std::vector<uint32_t> colors;
	colors.resize(num_colors);
	size_t sizeread = fread(colors.data(), sizeof(uint32_t) * num_colors,
				1, colors_file);
	if (sizeread != 1) {
		fprintf(stderr, "Can not read enough colors from %s\n",
			colors_path.c_str());
		abort();
	}
	fclose(colors_file);
	colors_file = NULL;
        return colors;
}

int generate_video_output(
	const Settings &settings,
	FILE *reg_file,
	const vector<uint32_t> &colors
	)
{
	if (settings.wave_path.size() == 0) {
		fprintf(stderr, "Need wave path: --wave path\n");
		return 1;
	}

	FILE *wave_file = fopen(settings.wave_path.c_str(), "wb");
	assert(wave_file != nullptr);

        // See https://docs.fileformat.com/audio/wav/

	// Later write size after RIFF at offset 4
	size_t sizewrite = fwrite("RIFF\x00\x00\x00\x00WAVEfmt ", 16, 1,
				  wave_file);
	assert(sizewrite == 1);
	sizewrite = fwrite("\x10\x00\x00\x00\x01\x00\x02\x00", 8, 1,
			   wave_file);
	assert(sizewrite == 1);

	// sample rate in LE binary
	const uint32_t sample_rate_le = htole32(settings.sample_rate);
	sizewrite = fwrite(&sample_rate_le, sizeof(sample_rate_le), 1,
			   wave_file);
	assert(sizewrite == 1);

	const uint32_t audio_frame_size = 4;
	const uint32_t bytes_per_second_le = htole32(
		settings.sample_rate * audio_frame_size);
	sizewrite = fwrite(&bytes_per_second_le, 4, 1, wave_file);
	assert(sizewrite == 1);

	// audio frame size in bytes
	const uint16_t audio_frame_size_le = htole32(audio_frame_size);
	sizewrite = fwrite(&audio_frame_size_le, 2, 1, wave_file);
	assert(sizewrite == 1);

	// 16 bits per sample
	sizewrite = fwrite("\x10\x00", 2, 1, wave_file);
	assert(sizewrite == 1);

	sizewrite = fwrite("data", 4, 1, wave_file);
	assert(sizewrite == 1);

	// Later write size after data at offset 40
	sizewrite = fwrite("\x00\x00\x00\x00", 4, 1, wave_file);
	assert(sizewrite == 1);

	AudioChannels audio_channels(NORMALIZATION_LENGTH);

	// Note: write native endianess, size_t number of Amiga frames
	//
	// TODO: Implement calculation of num_frames for progress meter.
	const size_t num_frames = 0;
	sizewrite = fwrite(&num_frames, sizeof(num_frames), 1, stdout);
	assert(sizewrite == 1);

	const size_t framebuffer_size = SCREEN_WIDTH * SCREEN_HEIGHT;
	vector<uint32_t> framebuffer(framebuffer_size);
	vector<uint32_t> aa_framebuffer(settings.aa_factor *
					settings.aa_factor *
					framebuffer_size);

	int frame_number = 0;
	FILE *csv_file = nullptr;
	if (settings.csv_path.size() > 0) {
		csv_file = fopen(settings.csv_path.c_str(), "w");
		assert(csv_file != nullptr);
		fprintf(csv_file, "frame\tchannel\tx\tamplitude\tnormalizer\tinstrument\n");
	}

	while (1) {
		struct uade_write_audio_frame frame;
		size_t sizeread = fread(&frame, sizeof(frame), 1, reg_file);
		if (sizeread == 0)
			break;

		const uint32_t tdeltawhole  = ntohl(frame.tdelta);
		// Read an unsigned 24-bit time delta value
		const uint32_t tdelta = tdeltawhole & 0xffffff;

		if (advance_time(&audio_channels, tdelta, &framebuffer,
				 colors, settings.aa_factor, &aa_framebuffer,
				 csv_file, frame_number)) {
			sizewrite = fwrite(
				framebuffer.data(),
				framebuffer_size * sizeof(framebuffer[0]),
				1, stdout);
			if (sizewrite != 1) {
				fprintf(stderr,
					"Unable to write the framebuffer\n");
				abort();
			}
			frame_number++;
		}

		const uint32_t tdelta_control = tdeltawhole >> 24;
		if (tdelta_control == 0) {
			// This frame contains new PCM values for each channel
			handle_paula_channel_output(&audio_channels, frame);
		} else if (tdelta_control == 0x80) {
			// This frame is a register write or a loop event
			handle_paula_event(&audio_channels, wave_file, frame,
					   settings, nullptr);
		} else {
			fprintf(stderr, "Unsupported control byte: %u."
				"This is probably a bug or a format "
				"extension.\n", tdelta_control);
			abort();
		}
	}

	if (csv_file != nullptr) {
		fclose(csv_file);
		csv_file = nullptr;
	}

	// Fix sizes in wave file header
	const size_t wave_size = ftell(wave_file);
	fseek(wave_file, 4, SEEK_SET);
	write_le32(wave_file, (uint32_t) wave_size - 8);
	fseek(wave_file, 40, SEEK_SET);
	write_le32(wave_file, (uint32_t) (wave_size - 44));
	fclose(wave_file);
	wave_file = nullptr;

	fclose(reg_file);
	return 0;
}

Normalizator::Normalizator(size_t length) : length_(length)
{
	data_.push_back(1.0);
}

void Normalizator::add_values(const vector<float> &values)
{
	if (length_ == 0)
		return;

	float maximum = EPSILON;
	for (auto x : values)
		maximum = std::max(maximum, std::abs(x));

	data_.push_back(1.0 / maximum);

	while (data_.size() > length_)
		data_.pop_front();
}

float Normalizator::get_normalizer() const
{
	float minimum = data_[0];

	for (auto x : data_) {
		minimum = std::min(minimum, x);
	}

	return minimum;
}

Channel::Channel() : value(0), len_(0), per_(0), lc_(0), buffer_nr_(0)
{
}

void Channel::advance_time(const int tdelta)
{
	for (int i = 0; i < tdelta; i++)
		time_window_.push_back(value);

	for (int i = 0; i < tdelta; i++)
		meta_window_.push_back(buffer_nr_);
}

void Channel::poll_time_window(
	vector<int16_t> *returned_time_window,
	vector<uint16_t> *returned_meta_window)
{
	// TODO: Clean this. The buffering is the same for all
	// channels, so calculating the ticks should be done only once.
	const size_t ticks = 3 * AMIGA_FRAME_TICKS / 2 + 1;
	const size_t threshold_size = std::max(ticks, VIDEO_FRAME_TICKS);
	if (time_window_.size() >= threshold_size) {
		// This is only done once in the beginning of the
		// stream
		returned_time_window->assign(
			time_window_.begin(),
			time_window_.begin() + ticks);
		CHECK(time_window_.size() >= VIDEO_FRAME_TICKS);

		returned_meta_window->assign(
			meta_window_.begin(),
			meta_window_.begin() + ticks);
		CHECK(meta_window_.size() >= VIDEO_FRAME_TICKS);

		// Drop output video frame time equivalent of Paula
		// outputs
		time_window_.erase(
			time_window_.begin(),
			time_window_.begin() + VIDEO_FRAME_TICKS);

		meta_window_.erase(
			meta_window_.begin(),
			meta_window_.begin() + (
				VIDEO_FRAME_TICKS));
	}
}

void handle_paula_channel_output(AudioChannels *channels,
				 const struct uade_write_audio_frame &frame)
{
	// Handle Audio channel output
	for (int i = 0; i < NUM_AMIGA_CHANNELS; i++) {
		channels->channels_[i].value = static_cast<int16_t>(
			ntohs(frame.data.output[i]));
	}
}

void handle_paula_event(AudioChannels *channels,
			FILE *wave_file,
			const struct uade_write_audio_frame &frame,
			const Settings &settings,
			vector<uint16_t> *accumulated_audio)
{
	const struct uade_paula_event_frame *pef = (
		&frame.data.paula_event_frame);
	auto channel_nr = pef->channel;
	assert(channel_nr >= 0 and channel_nr < NUM_AMIGA_CHANNELS);
	auto event_type = static_cast<enum UADEPaulaEventType>(
		pef->event_type);

	uint16_t event_value = ntohs(pef->event_value);
	Channel *channel = &channels->channels_[channel_nr];

	switch (event_type) {
	case PET_LEN:
		channel->len_ = event_value;
		break;
	case PET_LCH:
		channel->lc_ = (((uint32_t) event_value) << 16) | (
			channel->lc_ & 0xffff);
		break;
	case PET_LCL:
		channel->lc_ = (channel->lc_ & 0xffff0000) | event_value;
		break;
	case PET_PER:
		channel->per_ = event_value;
		break;
	case PET_OUTPUT:
		assert(channel_nr <= 1);
		channels->outputs_[channel_nr] = event_value;
		if (channel_nr == 1) {
			unsigned char wave_frame[4];

			// Convert audio channel output from biased PCM
			// in range [0, 65535] to integer range [-32768, 32767]
			int left = channels->outputs_[0];
			int right = channels->outputs_[1];
			if (left >= 32768)
				left -= 65536;
			if (right >= 32768)
				right -= 65536;

			// Do panning
			const int m = (right - left) * settings.panning;
			left += m;
			right -= m;

			const int serialized_left = (uint16_t) left;
			const int serialized_right = (uint16_t) right;
			wave_frame[0] = serialized_left & 0xff;
			wave_frame[1] = serialized_left >> 8;
			wave_frame[2] = serialized_right & 0xff;
			wave_frame[3] = serialized_right >> 8;
			if (wave_file != nullptr) {
				size_t ret = fwrite(&wave_frame, 4, 1, wave_file);
				assert(ret == 1);
			}

			if (accumulated_audio != nullptr) {
				accumulated_audio->push_back(serialized_left);
				accumulated_audio->push_back(serialized_right);
			}

			channels->outputs_[0] = 0;
			channels->outputs_[1] = 0;
		}
		break;
	case PET_START_BUFFER:
		if (channels->address_to_buffer_nr_.find(channel->lc_) ==
		    channels->address_to_buffer_nr_.end()) {
			uint16_t buffer_nr = (
				channels->address_to_buffer_nr_.size());
			channels->address_to_buffer_nr_[channel->lc_] = (
				buffer_nr);
		}
		channel->buffer_nr_ = channels->address_to_buffer_nr_.at(
			channel->lc_);
		break;
	default:
		break;
	}
}

bool advance_time(AudioChannels *audio_channels,
		  uint32_t tdelta,
		  vector<uint32_t> *framebuffer,
		  const vector<uint32_t> &colors,
		  const int aa_factor,
		  vector<uint32_t> *aa_framebuffer,
		  FILE *csv_file,
		  int frame_number)
{
	if (tdelta == 0)
		return false;

	vector<vector<float> > signals;
	vector<vector<uint16_t> > metas;
	for (auto &channel : audio_channels->channels_) {
		vector<float> signal;
		vector<uint16_t> meta;
		advance_time_on_channel(&signal, &meta, &channel, tdelta);

		if (signal.size() > 0) {
			audio_channels->normalizator.add_values(signal);

			signals.push_back(signal);
			metas.push_back(meta);
		}
	}

	if (signals.size() == 0)
		return false;

	assert(signals.size() == NUM_AMIGA_CHANNELS);

	const float normalizer = audio_channels->normalizator.get_normalizer();

	if (csv_file != nullptr) {
		for (unsigned int i = 0; i < NUM_AMIGA_CHANNELS; i++) {
			const vector<float> &channel_signal = signals[i];
			const vector<uint16_t> &channel_meta = metas[i];
			for (unsigned int j = 0; j < SAMPLES_PER_FRAME; j++) {
				const int x0 = PIXELS_PER_SAMPLE * j;
				fprintf(csv_file, "%d\t%d\t%d\t%f\t%f\t%d\n",
					frame_number, (int) i, x0,
					channel_signal[j], normalizer,
					(int) (channel_meta[j] % colors.size()));
			}
		}
	}

	if (!VIDEO_OUTPUT)
		return true;

	// Render channel scope within this many vertical pixels
	const unsigned int vertical_dim = (SCREEN_HEIGHT / NUM_AMIGA_CHANNELS -
                                           HEIGHT_MARGIN);
	const int aa_width = aa_factor * SCREEN_WIDTH;
	const int aa_height = aa_factor * SCREEN_HEIGHT;
	if (ANTIALIASING) {
		memset(aa_framebuffer->data(), 0,
		       aa_framebuffer->size() * sizeof((*aa_framebuffer)[0]));
	} else {
		memset(framebuffer->data(), 0,
		       framebuffer->size() * sizeof((*framebuffer)[0]));
	}

	for (unsigned int i = 0; i < NUM_AMIGA_CHANNELS; i++) {
		const int base_y = i * (vertical_dim + HEIGHT_MARGIN) +
			vertical_dim / 2;

		for (unsigned int j = 0; j < signals[i].size(); j++)
			signals[i][j] *= normalizer;

		const vector<float> &channel_signal = signals[i];
		const vector<uint16_t> &channel_meta = metas[i];

		for (unsigned int j = 0; j < SAMPLES_PER_FRAME; j++) {
			const int y0 = base_y + static_cast<int>(
				channel_signal[j] * (vertical_dim / 2 - 1));
			uint32_t color = colors[
				channel_meta[j] % colors.size()];
			const int x0 = PIXELS_PER_SAMPLE * j;
			const int x1 = PIXELS_PER_SAMPLE * (j + 1);

			if ((j + 1) < SAMPLES_PER_FRAME) {
				const int y1 = base_y + static_cast<int>(
					channel_signal[j + 1] * (
						vertical_dim / 2 - 1));
				if (ANTIALIASING) {
					draw_line_aa(
						aa_framebuffer,
						aa_factor * x0, aa_factor * y0,
						aa_factor * x1, aa_factor * y1,
						color,
						aa_factor * LINE_WIDTH,
						aa_width, aa_height);
				} else {
					draw_line(
						framebuffer,
						x0, y0,	x1, y1,
						color,
						SCREEN_WIDTH, SCREEN_HEIGHT);
				}
			}
		}
	}

	if (ANTIALIASING) {
		shrink_aa_framebuffer(framebuffer, aa_framebuffer,
				      SCREEN_WIDTH, SCREEN_HEIGHT,
				      aa_factor);
	}

	return true;
}

}  // namespace uade
}  // namespace write_audio
}  // namespace main


int main(int argc, char *argv[])
{
	vector<string> files;
	Settings settings;
	bool process_options = true;
	int write_audio_fd = -1;
	int num_colors = 0;
	string colors_path;
        unsigned int width = 1280;
        unsigned int height = 720;
	bool use_sdl = false;
	bool no_video = false;

	for (int i = 1; i < argc; ) {
		string s(argv[i]);
		if (process_options and s[0] == '-') {
			if (s == "--aa-factor") {
				CHECK((i + 1) < argc);
				int aa_factor = atoi(argv[i + 1]);
				if (aa_factor <= 0 ||
				    (aa_factor & (aa_factor - 1)) != 0) {
					fprintf(stderr,
						"--aa-factor must be a "
						"positive number which is a "
						"power of two\n");
					abort();
				}
				settings.aa_factor = aa_factor;
				i += 2;
			} else if (s == "--debug-audio") {
				settings.debug_audio_buffering = true;
				i++;
			} else if (s == "--fps") {
				CHECK((i + 1) < argc);
				settings.fps = atoi(argv[i + 1]);
				CHECK(settings.fps > 0);
				i += 2;
                        } else if (s == "--fullscreen" or s == "-f") {
				settings.fullscreen = true;
				i++;
                        } else if (s == "--width") {
				CHECK((i + 1) < argc);
				width = atoi(argv[i + 1]);
				i += 2;
			} else if (s == "--height") {
				CHECK((i + 1) < argc);
				height = atoi(argv[i + 1]);
				i += 2;
			} else if (s == "--no-antialiasing") {
				ANTIALIASING = false;
				i += 1;
			} else if (s == "--no-video") {
				no_video = true;
				i += 1;
			} else if (s == "--line-width") {
				CHECK((i + 1) < argc);
				LINE_WIDTH = atof(argv[i + 1]);
				CHECK(LINE_WIDTH > 0);
				i += 2;
			} else if (s == "--panning") {
				CHECK((i + 1) < argc);
				settings.panning = std::stof(argv[i + 1]);
				CHECK(settings.panning >= 0 &&
				       settings.panning <= 2);
				i += 2;
			} else if (s == "--wave") {
				CHECK((i + 1) < argc);
				CHECK(settings.wave_path.size() == 0);
				settings.wave_path = argv[i + 1];
				i += 2;
			} else if (s == "--write-audio-fd") {
				CHECK((i + 1) < argc);
				write_audio_fd = std::stoi(argv[i + 1]);
				CHECK(write_audio_fd >= 0);
				i += 2;
			} else if (s == "--colors") {
				CHECK((i + 2) < argc);
				num_colors = atoi(argv[i + 1]);
				colors_path = argv[i + 2];
				i += 3;
			} else if (s == "--csv-file") {
				CHECK((i + 1) < argc);
				settings.csv_path = argv[i + 1];
				i += 2;
                        } else if (s == "--sdl") {
				use_sdl = true;
				i++;
			} else if (s == "--") {
				process_options = false;
				i++;
			} else {
				CHECK(0);
			}
		} else {
			files.push_back(s);
			i++;
		}
	}

	if (!use_sdl and no_video)
		VIDEO_OUTPUT = false;

	if (files.size() > 1) {
		fprintf(stderr, "Only one register file may be given\n");
		return 1;
	}

	if (files.size() == 0 && write_audio_fd < 0)
		return 0;

	uade::write_audio::main::set_resolution(width, height);

	std::vector<uint32_t> colors = uade::write_audio::main::read_colors(
		num_colors, colors_path);

	VIDEO_FRAME_TICKS = SOUNDTICKS_PAL / settings.fps;

	assert((SAMPLES_PER_FRAME * PIXELS_PER_SAMPLE) == SCREEN_WIDTH);

	FILE *reg_file = nullptr;
	if (files.size() > 0) {
		reg_file = fopen(files[0].c_str(), "rb");
	} else {
		reg_file = fdopen(write_audio_fd, "rb");
		if (reg_file == nullptr) {
			fprintf(stderr, "Opening register file from fd %d "
				"failed: errno = %d (%s)\n",
				write_audio_fd, errno, strerror(errno));
			return 1;
		}
	}
	assert(reg_file != nullptr);

	const size_t HEADER_SIZE = 16;
	uint8_t header[HEADER_SIZE];
	size_t sizeread = fread(header, 1, HEADER_SIZE, reg_file);
	if (sizeread == 0) {
		fprintf(stderr, "Register file/stream is empty\n");
		return UADE_RET_INVALID_SONG;

	} else if (sizeread < HEADER_SIZE) {
		fprintf(stderr, "Register file/stream has an incomplete "
			"header\n");
		return 1;
	}

	if (memcmp(header, "uade_osc_0\x00\xec\x17\x31\x03\x09",
		   HEADER_SIZE)) {
		fprintf(stderr, "No magic header found in %s\n",
			files[0].c_str());
		return 1;
	}

	if (use_sdl) {
		return sdl_output(settings, reg_file, colors);
	} else {
		return generate_video_output(settings, reg_file, colors);
	}
}
