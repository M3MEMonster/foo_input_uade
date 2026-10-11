// TODO: Implement manual switch to fullscreen and non-fullscreen
// TODO: Implement jump to next subsong
// TODO: Implement backwards seeking

#include <arpa/inet.h>
#include <cassert>
#include <signal.h>

#include <SDL2/SDL.h>

#include "common.h"
#include "sdl_mode.h"

using std::vector;

using uade::write_audio::main::AudioChannels;
using uade::write_audio::main::Channel;
using uade::write_audio::main::Settings;
using uade::write_audio::main::NORMALIZATION_LENGTH;
using uade::write_audio::main::SCREEN_HEIGHT;
using uade::write_audio::main::SCREEN_WIDTH;
using uade::write_audio::main::VIDEO_OUTPUT;

namespace {

bool sigint_quit = false;

void sigint_handler(int signum)
{
	(void) signum;
	sigint_quit = true;
}

enum playback_mode {
	PLAYBACK_PLAY,
	PLAYBACK_PAUSED,
	PLAYBACK_SEEK,
};

class PlaybackControl
{
public:
	PlaybackControl()
	{
	}

	void set_debug()
	{
		debug_audio_buffering_ = true;
	}

	bool init(const int effective_sample_rate, const int fps)
	{
		assert(effective_sample_rate > 0 and fps > 0);
		sample_rate_ = effective_sample_rate;

		latency_ = 2.0 / fps;

		audio_bytes_per_frame_ = (
			((float) sample_rate_) * channels_ * 2 / fps);

		SDL_AudioSpec desired_spec;
		SDL_AudioSpec obtained_spec;
		SDL_memset(&desired_spec, 0, sizeof(desired_spec));
		desired_spec.freq = sample_rate_;
		desired_spec.format = AUDIO_S16SYS;  // 16-bit signed
		desired_spec.channels = channels_;
		desired_spec.samples = sample_rate_ / fps;

		// Open audio device
		audio_device_ = SDL_OpenAudioDevice(
			NULL, 0, &desired_spec, &obtained_spec, 0);
		if (audio_device_ == 0) {
			fprintf(stderr, "\nFailed to open audio device: %s\n",
				SDL_GetError());
			return false;
		}

		return true;
	}

	float get_queued_bytes() const
	{
		return SDL_GetQueuedAudioSize(audio_device_);
	}

	float get_queued_secs() const
	{
		uint32_t queued = get_queued_bytes();
		return ((float) queued) / (sample_rate_ * channels_ * 2);
	}

	void pause(int pause_on)
	{
		SDL_PauseAudioDevice(audio_device_, pause_on);
	}

	void seek(const float t)
	{
		if (t < 0)
			return;
		const int frames = (int) (t * sample_rate_);
		mode = PLAYBACK_SEEK;
		VIDEO_OUTPUT = false;
		// TODO: Try clear queued audio
		ssize_t offset = audio_offset_;
		offset += frames * channels_ * 2;
		if (offset < 0)
			offset = 0;
		seek_offset_ = offset;
	}

	void queue_audio(vector<uint16_t> *audio)
	{
		const size_t audio_size = audio->size() * sizeof((*audio)[0]);

		if (audio_size < audio_bytes_per_frame_ / 2)
			return;

		if (mode == PLAYBACK_SEEK) {
			// reverse seeking not implemented
			if ((audio_offset_ + audio_size) <= seek_offset_) {
				audio_offset_ += audio_size;
				audio->clear();
				return;
			}
			mode = PLAYBACK_PLAY;
			VIDEO_OUTPUT = true;
		}

		int ret = SDL_QueueAudio(audio_device_, audio->data(),
					 audio_size);
		if (ret < 0) {
			fprintf(stderr, "\nUnable to queue audio: %s\n",
				SDL_GetError());
			return;
		}

		audio_offset_ += audio_size;
		audio->clear();

		while (get_queued_secs() > latency_) {
			SDL_Delay(1);
		}

		if (debug_audio_buffering_) {
			fprintf(stderr, "audio frame %f audio queued %f\n",
				audio_offset_ / audio_bytes_per_frame_,
				get_queued_bytes() / audio_bytes_per_frame_);
		}
	}

	bool quit = false;
	enum playback_mode mode = PLAYBACK_PLAY;
	bool next = false;

private:

	float audio_bytes_per_frame_ = 0;
	int sample_rate_ = 0;
	int channels_ = 2;
	SDL_AudioDeviceID audio_device_ = 0;
	// Sleep if there is more than latency_ seconds of audio queued
	float latency_ = 0;

        size_t audio_offset_ = 0;
	bool debug_audio_buffering_ = false;
	size_t seek_offset_ = 0;
};

void render_to_texture(SDL_Texture *texture,
		       const vector<uint32_t> &framebuffer)
{
	uint32_t *buffer;
	int pitch;

	if (SDL_LockTexture(texture, NULL, (void **) &buffer, &pitch) < 0) {
		fprintf(stderr, "Failed to lock texture: %s\n",
			SDL_GetError());
		return;
	}

	// Get the pixel format
	uint32_t format;
	SDL_QueryTexture(texture, &format, NULL, NULL, NULL);
	SDL_PixelFormat *mapping_format = SDL_AllocFormat(format);

	// Calculate the number of bytes per pixel
	int bpp = mapping_format->BytesPerPixel;
	CHECK(bpp == 4);
	CHECK(((unsigned int) pitch) == SCREEN_WIDTH * bpp);

	for (unsigned int y = 0; y < SCREEN_HEIGHT; ++y) {
		for (unsigned int x = 0; x < SCREEN_WIDTH; ++x) {
			uint32_t color = framebuffer[y * SCREEN_WIDTH + x];
			buffer[y * SCREEN_WIDTH + x] = color;
		}
	}

	// Unlock the texture
	SDL_UnlockTexture(texture);

	// Free the pixel format structure
	SDL_FreeFormat(mapping_format);
}

void sdl_event_processing(PlaybackControl *control)
{
	SDL_Event e;
	while (!control->quit) {
		if (control->mode == PLAYBACK_PAUSED) {
			if (!SDL_WaitEvent(&e))
				break;
		} else {
			if (!SDL_PollEvent(&e))
				break;
		}
		switch (e.type) {
		case SDL_QUIT:
			control->quit = true;
			break;

		case SDL_KEYDOWN:
			switch (e.key.keysym.sym) {
			case 'q':
				control->quit = true;
				break;

			case 'p':
			case ' ':
				if (control->mode == PLAYBACK_PAUSED) {
					control->mode = PLAYBACK_PLAY;
				} else if (control->mode == PLAYBACK_PLAY) {
					control->mode = PLAYBACK_PAUSED;
				}
				break;
			case SDLK_F8:
			case SDLK_RETURN:
				control->next = true;
				control->quit = true;
				break;
			case SDLK_RIGHT:
				switch (control->mode) {
				case PLAYBACK_PAUSED:
				case PLAYBACK_PLAY:
				case PLAYBACK_SEEK:
					control->seek(10);
					break;
				}
			}
			break;
		}
	}
}

}  // anonymous namespace

namespace uade {
namespace write_audio {
namespace sdl_mode {

int sdl_output(
	const Settings &settings,
	FILE *reg_file,
	const vector<uint32_t> &colors
	)
{
	signal(SIGINT, sigint_handler);

	vector<uint32_t> native_endian_colors;
	for (size_t i = 0; i < colors.size(); i++) {
		// The RGBA colour was inserted into memory as a big-endian
		// uint32_t in write_audio.py. Hence, for, uint8_t *color,
		// color[0] is R, color[1] is G, ..., color[3] is A.
		uint8_t *bytes = (uint8_t *) &colors[i];
		uint32_t color = (bytes[0] << 24) + (bytes[1] << 16) +
			(bytes[2] << 8) + bytes[3];
		native_endian_colors.push_back(color);
	}

	// TODO: Audio buffer should be proportional to
	// 44100 * 4 / fps.

	AudioChannels audio_channels(NORMALIZATION_LENGTH);

	const size_t framebuffer_size = SCREEN_WIDTH * SCREEN_HEIGHT;
	vector<uint32_t> framebuffer(framebuffer_size);
	vector<uint32_t> aa_framebuffer(
		settings.aa_factor * settings.aa_factor * framebuffer_size);

	// Initialize SDL
	if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO) < 0) {
		fprintf(stderr, "SDL could not initialize! SDL_Error: %s\n",
			SDL_GetError());
		return 1;
	}

	// Create window
        uint32_t window_flags = SDL_WINDOW_SHOWN;

        if (settings.fullscreen)
		window_flags |= SDL_WINDOW_FULLSCREEN_DESKTOP;

	SDL_Window* window = SDL_CreateWindow(
		"uade",
		SDL_WINDOWPOS_UNDEFINED,
		SDL_WINDOWPOS_UNDEFINED,
		SCREEN_WIDTH, SCREEN_HEIGHT,
		window_flags
            );
	if (window == nullptr) {
		fprintf(stderr, "Window could not be created! SDL_Error: %s\n",
			SDL_GetError());
		return 1;
	}

	// Create renderer
	SDL_Renderer* renderer = SDL_CreateRenderer(
            window, -1,
	    // Do not use SDL_RENDERER_PRESENTVSYNC. Audio and video are
	    // synchronized by the register event state machine. The state
	    // machine determines when to flip image (without delay).
            SDL_RENDERER_ACCELERATED
            );

	if (renderer == nullptr) {
		fprintf(stderr, "Renderer could not be created! "
			"SDL_Error: %s\n", SDL_GetError());
		return 1;
	}

	// Create a texture to use as the framebuffer
	SDL_Texture* framebuffer_texture = SDL_CreateTexture(
		renderer,
		SDL_PIXELFORMAT_RGBA8888,
		SDL_TEXTUREACCESS_STREAMING,
		SCREEN_WIDTH, SCREEN_HEIGHT);
	if (framebuffer_texture == nullptr) {
		fprintf(stderr,
			"Texture could not be created! SDL_Error: %s\n",
			SDL_GetError());
		return 1;
	}

	vector<uint16_t> accumulated_audio;

        PlaybackControl control;

        if (!control.init(settings.sample_rate, settings.fps))
		return 1;

	if (settings.debug_audio_buffering)
		control.set_debug();

        control.pause(0);

	while (!control.quit && !sigint_quit) {
		struct uade_write_audio_frame frame;
		size_t sizeread = fread(&frame, sizeof(frame), 1, reg_file);
		if (sizeread == 0)
			break;

		const uint32_t tdeltawhole  = ntohl(frame.tdelta);
		// Read an unsigned 24-bit time delta value
		const uint32_t tdelta = tdeltawhole & 0xffffff;

		if (advance_time(&audio_channels, tdelta, &framebuffer,
				 native_endian_colors, settings.aa_factor,
				 &aa_framebuffer, nullptr, 0)) {
			sdl_event_processing(&control);

			if (control.quit)
				continue;

			if (VIDEO_OUTPUT) {
				// Render to the texture
				render_to_texture(framebuffer_texture,
						  framebuffer);

				// Clear the renderer
				SDL_RenderClear(renderer);

				// Copy the texture to the renderer
				SDL_RenderCopy(renderer, framebuffer_texture,
					       NULL, NULL);

				// Present the renderer
				SDL_RenderPresent(renderer);
			}
		}

		const uint32_t tdelta_control = tdeltawhole >> 24;
		if (tdelta_control == 0) {
			// This frame contains new PCM values for each channel
			handle_paula_channel_output(&audio_channels, frame);
		} else if (tdelta_control == 0x80) {
			// This frame is a register write or a loop event
			handle_paula_event(&audio_channels, nullptr, frame,
					   settings, &accumulated_audio);
			control.queue_audio(&accumulated_audio);
		} else {
			fprintf(stderr, "Unsupported control byte: %u."
				"This is probably a bug or a format "
				"extension.\n", tdelta_control);
			abort();
		}
	}

	fclose(reg_file);

	if (control.quit || sigint_quit) {
		if (control.next)
			return UADE_RET_NEXT;

		return UADE_RET_QUIT;
	}

	return 0;
}

}  // namespace sdl_mode
}  // namespace write_audio
}  // namespace uade
