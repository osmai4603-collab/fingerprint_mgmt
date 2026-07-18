import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class ChangeLanguageEvent extends SettingsEvent {
  final Locale locale;
  const ChangeLanguageEvent(this.locale);

  @override
  List<Object?> get props => [locale];
}

class ChangeThemeEvent extends SettingsEvent {
  final ThemeMode themeMode;
  const ChangeThemeEvent(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}
