#pragma once
#include "stdafx.h"

extern cfg_int cfg_uade_samplerate;
extern cfg_int cfg_uade_filter;
extern cfg_int cfg_uade_resampler;
extern cfg_int cfg_uade_clock;
extern cfg_bool cfg_uade_mute1;
extern cfg_bool cfg_uade_mute2;
extern cfg_bool cfg_uade_mute3;
extern cfg_bool cfg_uade_mute4;
extern cfg_int cfg_uade_default_length;
extern cfg_bool cfg_uade_indef_play;
extern cfg_bool cfg_uade_enable_gain;
extern cfg_double cfg_uade_gain;
extern cfg_bool cfg_uade_headphone;
extern cfg_bool cfg_uade_headphone2;
extern cfg_double cfg_uade_pan;
extern cfg_bool cfg_uade_ignore_player_check;

enum CLOCK { INPUT_SPECIFIC = 0, PAL = 1, NTSC = 2 };
enum FILTER { A500 = 0, A1200 = 1, FILTER_NONE = 2 };
enum RESAMPLER { DEFAULT = 0, SINC = 1, RESAMPLER_NONE = 2 };

inline constexpr int default_sample_rate_idx = 5;  // 44100 Hz
inline constexpr int default_filter = FILTER::A500;  // A500
inline constexpr int default_resampler = RESAMPLER::DEFAULT;  // "default"
inline constexpr int default_clock = CLOCK::INPUT_SPECIFIC;
inline constexpr bool default_mute1 = false;
inline constexpr bool default_mute2 = false;
inline constexpr bool default_mute3 = false;
inline constexpr bool default_mute4 = false;
inline constexpr int default_default_length = 180;  //180s, 3min
inline constexpr bool default_is_indef_play = false;
inline constexpr bool default_is_enable_gain = false;
inline constexpr double default_uade_gain = 1.0;
inline constexpr bool default_uade_headphone = false;
inline constexpr bool default_uade_headphone2 = false;
inline constexpr double default_uade_pan = 0.7;
inline constexpr bool default_is_ignore_player_check = false;

inline const char* sample_rate_table[] = { "8000","11025","16000","22050","32000","44100","48000","64000","88200","96000" };
inline constexpr int sample_table_count = (int)sizeof(sample_rate_table) / (int)sizeof(sample_rate_table[0]);
inline const char* filter_table[] = { "A500","A1200","none" };
inline const char* resampler_table[] = { "default","sinc","none" };



