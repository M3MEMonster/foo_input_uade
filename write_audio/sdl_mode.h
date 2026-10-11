#ifndef _UADE_WRITE_AUDIO_SDL_MODE_H_
#define _UADE_WRITE_AUDIO_SDL_MODE_H_

#include <vector>
#include <cstdint>
#include <cstdio>

#include "main.h"

namespace uade {
namespace write_audio {
namespace sdl_mode {

int sdl_output(
	const uade::write_audio::main::Settings &settings,
	FILE *reg_file,
	const std::vector<uint32_t> &colors
	);


}  // namespace sdl_mode
}  // namespace write_audio
}  // namespace uade

#endif
