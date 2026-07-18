import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences sharedPreferences;

  static const String _localeKey = 'app_locale';
  static const String _themeKey = 'app_theme';

  SettingsBloc({required this.sharedPreferences}) : super(const SettingsState()) {
    on<ChangeLanguageEvent>(_onChangeLanguage);
    on<ChangeThemeEvent>(_onChangeTheme);
    _loadSettings();
  }

  void _loadSettings() {
    // Load Locale
    final String? localeStr = sharedPreferences.getString(_localeKey);
    Locale locale = const Locale('ar', '');
    if (localeStr != null) {
      locale = Locale(localeStr, '');
    }

    // Load Theme
    final String? themeStr = sharedPreferences.getString(_themeKey);
    ThemeMode themeMode = ThemeMode.system;
    if (themeStr != null) {
      if (themeStr == 'light') {
        themeMode = ThemeMode.light;
      } else if (themeStr == 'dark') {
        themeMode = ThemeMode.dark;
      }
    }

    // Emit initial state
    emit(state.copyWith(locale: locale, themeMode: themeMode));
  }

  Future<void> _onChangeLanguage(
    ChangeLanguageEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await sharedPreferences.setString(_localeKey, event.locale.languageCode);
    emit(state.copyWith(locale: event.locale));
  }

  Future<void> _onChangeTheme(
    ChangeThemeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    String themeStr = 'system';
    if (event.themeMode == ThemeMode.light) {
      themeStr = 'light';
    } else if (event.themeMode == ThemeMode.dark) {
      themeStr = 'dark';
    }
    
    await sharedPreferences.setString(_themeKey, themeStr);
    emit(state.copyWith(themeMode: event.themeMode));
  }
}
