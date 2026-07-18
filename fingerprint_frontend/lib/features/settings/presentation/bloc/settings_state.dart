import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  final Locale locale;
  final ThemeMode themeMode;

  const SettingsState({
    this.locale = const Locale('ar', ''),
    this.themeMode = ThemeMode.system,
  });

  SettingsState copyWith({
    Locale? locale,
    ThemeMode? themeMode,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [locale, themeMode];
}
