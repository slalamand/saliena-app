import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saliena_app/features/settings/domain/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository settingsRepository;

  SettingsBloc({required this.settingsRepository}) : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<ChangeLanguage>(_onChangeLanguage);
    on<ChangeTheme>(_onChangeTheme);
  }

  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    try {
      final languageCode = await settingsRepository.getLanguage();
      final themeModeStr = await settingsRepository.getTheme();

      final locale = languageCode != null ? Locale(languageCode) : const Locale('en');
      final themeMode = _parseThemeMode(themeModeStr);

      emit(state.copyWith(
        locale: locale,
        themeMode: themeMode,
        isLoading: false,
      ));
    } catch (e) {
      // Fallback to default on error
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onChangeLanguage(ChangeLanguage event, Emitter<SettingsState> emit) async {
    await settingsRepository.saveLanguage(event.locale.languageCode);
    emit(state.copyWith(locale: event.locale));
  }

  Future<void> _onChangeTheme(ChangeTheme event, Emitter<SettingsState> emit) async {
    await settingsRepository.saveTheme(event.themeMode.toString());
    emit(state.copyWith(themeMode: event.themeMode));
  }

  ThemeMode _parseThemeMode(String? themeModeStr) {
    if (themeModeStr == null) return ThemeMode.system;
    try {
      return ThemeMode.values.firstWhere(
        (e) => e.toString() == themeModeStr,
        orElse: () => ThemeMode.system,
      );
    } catch (_) {
      return ThemeMode.system;
    }
  }
}
