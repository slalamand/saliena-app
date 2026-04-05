import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final Locale locale;
  final ThemeMode themeMode;
  final bool isLoading;

  const SettingsState({
    this.locale = const Locale('en'),
    this.themeMode = ThemeMode.system,
    this.isLoading = true,
  });

  SettingsState copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    bool? isLoading,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [locale, themeMode, isLoading];
}
