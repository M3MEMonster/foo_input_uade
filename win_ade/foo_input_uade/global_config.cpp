#include "stdafx.h"
#include "GUID.h"
#include "global_config.h"

cfg_int cfg_uade_samplerate(guid_cfg_samplerate, default_sample_rate_idx);
cfg_int cfg_uade_filter(guid_cfg_filter, default_filter);
cfg_int cfg_uade_resampler(guid_cfg_resampler, default_resampler);
cfg_int cfg_uade_clock(guid_cfg_clock, default_clock);
cfg_bool cfg_uade_mute1(guid_cfg_mute1, default_mute1);
cfg_bool cfg_uade_mute2(guid_cfg_mute2, default_mute2);
cfg_bool cfg_uade_mute3(guid_cfg_mute3, default_mute3);
cfg_bool cfg_uade_mute4(guid_cfg_mute4, default_mute4);
cfg_int cfg_uade_default_length(guid_cfg_default_length, default_default_length);
cfg_bool cfg_uade_indef_play(guid_cfg_indef_play, default_is_indef_play);
cfg_bool cfg_uade_enable_gain(guid_cfg_enable_gain, default_is_enable_gain);
cfg_double cfg_uade_gain(guid_cfg_gain, default_uade_gain);
cfg_bool cfg_uade_headphone(guid_cfg_hp1, default_uade_headphone);
cfg_bool cfg_uade_headphone2(guid_cfg_hp2, default_uade_headphone2);
cfg_double cfg_uade_pan(guid_cfg_pan, default_uade_pan);
cfg_bool cfg_uade_ignore_player_check(guid_cfg_ignore_check, default_is_ignore_player_check);