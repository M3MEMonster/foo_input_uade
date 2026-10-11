#include "stdafx.h"
#include "resource.h"
#include <helpers/atl-misc.h>
#include <helpers/DarkMode.h>
#include <string>
#include <algorithm>
#include "global_config.h"
#include "GUID.h"

class CUADEPreferences : public CDialogImpl<CUADEPreferences>, public preferences_page_instance {
private:
	preferences_page_callback::ptr m_callback;
	fb2k::CDarkModeHooks m_dark;
	int m_set_samplerate;
	int m_set_filter;
	int m_set_resampler;
	int m_set_clock;
	bool m_set_mute1;
	bool m_set_mute2;
	bool m_set_mute3;
	bool m_set_mute4;
	int m_set_default_length;
	bool m_set_indef_play;
	bool m_set_enable_gain;
	double m_set_gain;
	bool m_set_headphone;
	bool m_set_headphone2;
	double m_set_pan;
	bool m_set_ignore_player_check;
public:
	CUADEPreferences(preferences_page_callback::ptr callback) : m_callback(callback) {};
	enum { IDD = IDD_UADE_PREF };
	t_uint32 get_state() {
		t_uint32 state = preferences_state::dark_mode_supported | preferences_state::resettable;
		if (HasChanged()) state |= preferences_state::changed;
		return state;
	}
	void apply() {
		cfg_uade_samplerate = m_set_samplerate;
		cfg_uade_filter = m_set_filter;
		cfg_uade_resampler = m_set_resampler;
		cfg_uade_clock = m_set_clock;
		cfg_uade_mute1 = m_set_mute1;
		cfg_uade_mute2 = m_set_mute2;
		cfg_uade_mute3 = m_set_mute3;
		cfg_uade_mute4 = m_set_mute4;
		cfg_uade_default_length = m_set_default_length;
		cfg_uade_indef_play = m_set_indef_play;
		cfg_uade_enable_gain = m_set_enable_gain;
		cfg_uade_gain = m_set_gain;
		cfg_uade_headphone = m_set_headphone;
		cfg_uade_headphone2 = m_set_headphone2;
		cfg_uade_pan = m_set_pan;
		cfg_uade_ignore_player_check = m_set_ignore_player_check;
		OnChanged();
	}
	void reset() {
		m_set_samplerate = default_sample_rate_idx;
		m_set_filter = default_filter;
		m_set_resampler = default_resampler;
		m_set_clock = default_clock;
		m_set_mute1 = default_mute1;
		m_set_mute2 = default_mute2;
		m_set_mute3 = default_mute3;
		m_set_mute4 = default_mute4;
		m_set_default_length = default_default_length;
		m_set_indef_play = default_is_indef_play;
		m_set_enable_gain = default_is_enable_gain;
		m_set_gain = default_uade_gain;
		m_set_headphone = default_uade_headphone;
		m_set_headphone2 = default_uade_headphone2;
		m_set_pan = default_uade_pan;
		m_set_ignore_player_check = default_is_ignore_player_check;
		CComboBox sample_combo(GetDlgItem(IDC_COMBO_SAMPLE));
		CComboBox filter_combo(GetDlgItem(IDC_COMBO_FILTER));
		CComboBox resampler_combo(GetDlgItem(IDC_COMBO_RESAMPLE));
		CComboBox clock_combo(GetDlgItem(IDC_COMBO_CLOCK));
		sample_combo.SetCurSel(default_sample_rate_idx);//default: 44100 Hz
		filter_combo.SetCurSel(default_filter);
		resampler_combo.SetCurSel(default_resampler);
		clock_combo.SetCurSel(default_clock);
		wchar_t dl_buffer[32], ga_buffer[32], pan_buffer[32];
		swprintf_s(dl_buffer, L"%d", default_default_length);
		swprintf_s(ga_buffer, L"%.2f", default_uade_gain);
		swprintf_s(pan_buffer, L"%.1f", default_uade_pan);
		SetDlgItemTextW(IDC_EDIT_LEN, dl_buffer);
		SetDlgItemTextW(IDC_EDIT_GAIN, ga_buffer);
		SetDlgItemTextW(IDC_PAN_VALUE, pan_buffer);
		CheckDlgButton(IDC_MUTE1, BST_UNCHECKED);
		CheckDlgButton(IDC_MUTE2, BST_UNCHECKED);
		CheckDlgButton(IDC_MUTE3, BST_UNCHECKED);
		CheckDlgButton(IDC_MUTE4, BST_UNCHECKED);
		CheckDlgButton(IDC_INF_PLAY, BST_UNCHECKED);
		CheckDlgButton(IDC_ENABLE_GAIN, BST_UNCHECKED);
		CheckDlgButton(IDC_HEADPHONE, BST_UNCHECKED);
		CheckDlgButton(IDC_HEADPHONE2, BST_UNCHECKED);
		CheckDlgButton(IDC_CHECK_IGNORE, BST_UNCHECKED);
		SendDlgItemMessage(IDC_LEN_SPIN, UDM_SETPOS32, 0, (int)default_default_length);
		SendDlgItemMessage(IDC_GAIN_SPIN, UDM_SETPOS32, 0, static_cast<LPARAM>(std::lround((double)default_uade_gain * 100.0)));
		SendDlgItemMessage(IDC_PAN, TBM_SETPOS, TRUE, static_cast<LPARAM>(default_uade_pan * 10.0 + 0.5));
		GetDlgItem(IDC_EDIT_GAIN).EnableWindow(FALSE);
		GetDlgItem(IDC_GAIN_SPIN).EnableWindow(FALSE);
		OnChanged();
	}
	void OnChanged() {
		m_callback->on_state_changed();
	}
	bool HasChanged() {
		return m_set_samplerate != (int)cfg_uade_samplerate || m_set_filter != (int)cfg_uade_filter
			|| m_set_resampler != (int)cfg_uade_resampler || m_set_clock != (int)cfg_uade_clock
			|| m_set_mute1 != (bool)cfg_uade_mute1 || m_set_mute2 != (bool)cfg_uade_mute2
			|| m_set_mute3 != (bool)cfg_uade_mute3 || m_set_mute4 != (bool)cfg_uade_mute4
			|| m_set_default_length != (int)cfg_uade_default_length
			|| m_set_indef_play != (int)cfg_uade_indef_play || m_set_enable_gain != (bool)cfg_uade_enable_gain
			|| m_set_gain != (double)cfg_uade_gain || m_set_headphone != (bool)cfg_uade_headphone
			|| m_set_headphone2 != (bool)cfg_uade_headphone2 || m_set_pan != (double)cfg_uade_pan
			|| m_set_ignore_player_check != (bool)cfg_uade_ignore_player_check;
	}
	BEGIN_MSG_MAP_EX(CUADEPreferences)
		MSG_WM_INITDIALOG(OnInitDialog)
		COMMAND_HANDLER_EX(IDC_COMBO_SAMPLE,CBN_SELCHANGE,OnSampleChange)
		COMMAND_HANDLER_EX(IDC_COMBO_FILTER, CBN_SELCHANGE, OnFilterChange)
		COMMAND_HANDLER_EX(IDC_COMBO_RESAMPLE, CBN_SELCHANGE, OnResamplerChange)
		COMMAND_HANDLER_EX(IDC_COMBO_CLOCK, CBN_SELCHANGE, OnClockChange)
		COMMAND_HANDLER_EX(IDC_MUTE1, BN_CLICKED, IsMute)
		COMMAND_HANDLER_EX(IDC_MUTE2, BN_CLICKED, IsMute)
		COMMAND_HANDLER_EX(IDC_MUTE3, BN_CLICKED, IsMute)
		COMMAND_HANDLER_EX(IDC_MUTE4, BN_CLICKED, IsMute)
		COMMAND_HANDLER_EX(IDC_EDIT_LEN, EN_CHANGE, OnDefaultLenChange)
		COMMAND_HANDLER_EX(IDC_EDIT_GAIN, EN_CHANGE, OnGainValueChange)
		COMMAND_HANDLER_EX(IDC_ENABLE_GAIN, BN_CLICKED, IsGainEnable)
		NOTIFY_HANDLER(IDC_GAIN_SPIN, UDN_DELTAPOS, OnGainSpinChange)
		COMMAND_HANDLER_EX(IDC_INF_PLAY, BN_CLICKED, IsPlayIndef)
		COMMAND_HANDLER_EX(IDC_HEADPHONE, BN_CLICKED, IsHp1)
		COMMAND_HANDLER_EX(IDC_HEADPHONE2, BN_CLICKED, IsHp2)
		COMMAND_HANDLER_EX(IDC_CHECK_IGNORE,BN_CLICKED,IsIgnoreCheck)
		MESSAGE_HANDLER(WM_HSCROLL,OnPanChange)
	END_MSG_MAP()
	BOOL OnInitDialog(CWindow, LPARAM) {
		m_dark.AddDialogWithControls(*this);
		m_set_samplerate = cfg_uade_samplerate;
		m_set_filter = cfg_uade_filter;
		m_set_resampler = cfg_uade_resampler;
		m_set_clock = cfg_uade_clock;
		m_set_mute1 = cfg_uade_mute1;
		m_set_mute2 = cfg_uade_mute2;
		m_set_mute3 = cfg_uade_mute3;
		m_set_mute4 = cfg_uade_mute4;
		m_set_default_length = cfg_uade_default_length;
		m_set_indef_play = cfg_uade_indef_play;
		m_set_enable_gain = cfg_uade_enable_gain;
		m_set_gain = cfg_uade_gain;
		m_set_headphone = cfg_uade_headphone;
		m_set_headphone2 = cfg_uade_headphone2;
		m_set_pan = cfg_uade_pan;
		m_set_ignore_player_check = cfg_uade_ignore_player_check;
		CComboBox sample_combo(GetDlgItem(IDC_COMBO_SAMPLE));
		for (int i = 0; i < sample_table_count; i++) {
			wchar_t buffer[32];
			wsprintfW(buffer, L"%S Hz", sample_rate_table[i]);
			SendDlgItemMessage(IDC_COMBO_SAMPLE, CB_ADDSTRING, 0, (LPARAM)buffer);
		}
		CComboBox filter_combo(GetDlgItem(IDC_COMBO_FILTER));
		filter_combo.AddString(L"A500");
		filter_combo.AddString(L"A1200");
		filter_combo.AddString(L"none");
		CComboBox resampler_combo(GetDlgItem(IDC_COMBO_RESAMPLE));
		resampler_combo.AddString(L"default");
		resampler_combo.AddString(L"sinc");
		resampler_combo.AddString(L"none");
		CComboBox clock_combo(GetDlgItem(IDC_COMBO_CLOCK));
		clock_combo.AddString(L"As input file specifies");
		clock_combo.AddString(L"Force PAL");
		clock_combo.AddString(L"Force NTSC");
		sample_combo.SetCurSel((int)cfg_uade_samplerate);//default: 44100 Hz
		filter_combo.SetCurSel((int)cfg_uade_filter);
		resampler_combo.SetCurSel((int)cfg_uade_resampler);
		clock_combo.SetCurSel((int)cfg_uade_clock);
		wchar_t dl_buffer[32], ga_buffer[32], pan_buffer[32];
		swprintf_s(dl_buffer, L"%d", (int)cfg_uade_default_length);
		swprintf_s(ga_buffer, L"%.2f", (double)cfg_uade_gain);
		swprintf_s(pan_buffer, L"%.1f", (double)cfg_uade_pan);
		SetDlgItemTextW(IDC_EDIT_LEN, dl_buffer);
		SetDlgItemTextW(IDC_EDIT_GAIN, ga_buffer);
		SetDlgItemTextW(IDC_PAN_VALUE, pan_buffer);
		CheckDlgButton(IDC_MUTE1, (bool)cfg_uade_mute1 ? BST_CHECKED : BST_UNCHECKED);
		CheckDlgButton(IDC_MUTE2, (bool)cfg_uade_mute2 ? BST_CHECKED : BST_UNCHECKED);
		CheckDlgButton(IDC_MUTE3, (bool)cfg_uade_mute3 ? BST_CHECKED : BST_UNCHECKED);
		CheckDlgButton(IDC_MUTE4, (bool)cfg_uade_mute4 ? BST_CHECKED : BST_UNCHECKED);
		CheckDlgButton(IDC_INF_PLAY, (bool)cfg_uade_indef_play ? BST_CHECKED : BST_UNCHECKED);
		CheckDlgButton(IDC_ENABLE_GAIN, (bool)cfg_uade_enable_gain ? BST_CHECKED : BST_UNCHECKED);
		CheckDlgButton(IDC_HEADPHONE, (bool)cfg_uade_headphone ? BST_CHECKED : BST_UNCHECKED);
		CheckDlgButton(IDC_HEADPHONE2, (bool)cfg_uade_headphone2 ? BST_CHECKED : BST_UNCHECKED);
		CheckDlgButton(IDC_CHECK_IGNORE, (bool)cfg_uade_ignore_player_check ? BST_CHECKED : BST_UNCHECKED);
		SendDlgItemMessage(IDC_LEN_SPIN, UDM_SETBUDDY, reinterpret_cast<WPARAM>(GetDlgItem(IDC_EDIT_LEN).m_hWnd), 0);
		SendDlgItemMessage(IDC_GAIN_SPIN, UDM_SETBUDDY, reinterpret_cast<WPARAM>(GetDlgItem(IDC_EDIT_GAIN).m_hWnd), 0);
		SendDlgItemMessage(IDC_LEN_SPIN, UDM_SETRANGE32, 0, 65535);
		SendDlgItemMessage(IDC_GAIN_SPIN, UDM_SETRANGE32, 0, 12800);
		UDACCEL LenStep = { 0,1 }, GainStep = { 0,10 };
		SendDlgItemMessage(IDC_LEN_SPIN, UDM_SETACCEL, 1, reinterpret_cast<LPARAM>(&LenStep));
		SendDlgItemMessage(IDC_GAIN_SPIN, UDM_SETACCEL, 1, reinterpret_cast<LPARAM>(&GainStep));
		SendDlgItemMessage(IDC_LEN_SPIN, UDM_SETPOS32, 0, (int)cfg_uade_default_length);
		SendDlgItemMessage(IDC_GAIN_SPIN, UDM_SETPOS32, 0, static_cast<LPARAM>(std::lround((double)cfg_uade_gain * 100.0)));
		SendDlgItemMessage(IDC_PAN, TBM_SETRANGE, TRUE, MAKELPARAM(0, 20));
		SendDlgItemMessage(IDC_PAN, TBM_SETPOS, TRUE, static_cast<LPARAM>((double)cfg_uade_pan * 10.0 + 0.5));
		if (!(bool)cfg_uade_enable_gain) {
			GetDlgItem(IDC_EDIT_GAIN).EnableWindow(FALSE);
		}
		else {
			GetDlgItem(IDC_EDIT_GAIN).EnableWindow(TRUE);
		}
		return FALSE;
	}
	void OnSampleChange(UINT, int ctl, CWindow) {
		CComboBox combo(GetDlgItem(ctl));
		m_set_samplerate = combo.GetCurSel();
		OnChanged();
	}
	void OnFilterChange(UINT, int ctl, CWindow) {
		CComboBox combo(GetDlgItem(ctl));
		m_set_filter = combo.GetCurSel();
		OnChanged();
	}
	void OnResamplerChange(UINT, int ctl, CWindow) {
		CComboBox combo(GetDlgItem(ctl));
		m_set_resampler = combo.GetCurSel();
		OnChanged();
	}
	void OnClockChange(UINT, int ctl, CWindow) {
		CComboBox combo(GetDlgItem(ctl));
		m_set_clock = combo.GetCurSel();
		OnChanged();
	}
	void IsMute(UINT, int, CWindow) {
		m_set_mute1 = IsDlgButtonChecked(IDC_MUTE1);
		m_set_mute2 = IsDlgButtonChecked(IDC_MUTE2);
		m_set_mute3 = IsDlgButtonChecked(IDC_MUTE3);
		m_set_mute4 = IsDlgButtonChecked(IDC_MUTE4);
		OnChanged();
	}
	void OnDefaultLenChange(UINT, int, CWindow) {
		CString length;
		GetDlgItemTextW(IDC_EDIT_LEN, length);
		try {
			int length_i = std::stoi(std::wstring(length.GetString()));
			if (length_i < 0 || length_i>65535) return;
			m_set_default_length = length_i;
		}
		catch (...) { return; }
		OnChanged();
	}
	LRESULT OnGainSpinChange(int, LPNMHDR hdr, BOOL&) {
		const auto* spin = reinterpret_cast<LPNMUPDOWN>(hdr);
		const int ticks = std::clamp(spin->iPos + spin->iDelta, 0, 12800);
		m_set_gain = ticks / 100.0;
		wchar_t buffer[32];
		swprintf_s(buffer, L"%.2f", m_set_gain);
		SetDlgItemTextW(IDC_EDIT_GAIN, buffer);
		OnChanged();
		return 0;
	}
	void OnGainValueChange(UINT, int, CWindow) {
		GetDlgItem(IDC_EDIT_GAIN).EnableWindow(TRUE);
		CString gain;
		GetDlgItemTextW(IDC_EDIT_GAIN, gain);
		try {
			double gain_d = _tstof(gain);
			if (gain_d < 0 || gain_d>128) return;
			m_set_gain = gain_d;
		}
		catch (...) { return; }
		OnChanged();
	}
	void IsGainEnable(UINT, int, CWindow) {
		m_set_enable_gain = IsDlgButtonChecked(IDC_ENABLE_GAIN);
		if (!m_set_enable_gain) {
			GetDlgItem(IDC_EDIT_GAIN).EnableWindow(FALSE);
			GetDlgItem(IDC_GAIN_SPIN).EnableWindow(FALSE);
		}
		else {
			GetDlgItem(IDC_EDIT_GAIN).EnableWindow(TRUE);
			GetDlgItem(IDC_GAIN_SPIN).EnableWindow(TRUE);
		}
		OnChanged();
	}
	void IsPlayIndef(UINT, int, CWindow) {
		m_set_indef_play = IsDlgButtonChecked(IDC_INF_PLAY);
		OnChanged();
	}
	void IsHp1(UINT, int, CWindow) {
		m_set_headphone = IsDlgButtonChecked(IDC_HEADPHONE);
		OnChanged();
	}
	void IsHp2(UINT, int, CWindow) {
		m_set_headphone2 = IsDlgButtonChecked(IDC_HEADPHONE2);
		OnChanged();
	}
	void IsIgnoreCheck(UINT, int, CWindow) {
		m_set_ignore_player_check = IsDlgButtonChecked(IDC_CHECK_IGNORE);
		OnChanged();
	}
	LRESULT OnPanChange(UINT, WPARAM, LPARAM lparam, BOOL& handled) {
		if (reinterpret_cast<HWND>(lparam) != GetDlgItem(IDC_PAN)) {
			handled = FALSE;
			return 0;
		}
		const int pos = static_cast<int>(SendDlgItemMessage(IDC_PAN, TBM_GETPOS));
		m_set_pan = pos / 10.0;
		wchar_t text[32];
		swprintf_s(text, L"%.1f", m_set_pan);
		SetDlgItemTextW(IDC_PAN_VALUE, text);
		OnChanged();
		return 0;
	}
};

class preferences_page_uade_input_impl : public preferences_page_impl<CUADEPreferences> {
public:
	const char* get_name() { return "UADE Input"; }
	GUID get_guid() { return guid_preference; }
	GUID get_parent_guid() { return preferences_page::guid_input; }
};

static preferences_page_factory_t<preferences_page_uade_input_impl> g_preferences_page_uade_input_impl_factory;