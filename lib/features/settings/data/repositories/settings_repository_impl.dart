import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:saliena_app/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final FlutterSecureStorage _storage;
  static const String _kLanguageKey = 'language_code';
  static const String _kThemeKey = 'theme_mode';
  static const String _kMapFilterKey = 'map_filter_statuses';

  SettingsRepositoryImpl(this._storage);

  @override
  Future<String?> getLanguage() async {
    try {
      return await _storage.read(key: _kLanguageKey);
    } catch (e) {
      // Return default if secure storage fails
      return null;
    }
  }

  @override
  Future<void> saveLanguage(String languageCode) async {
    try {
      await _storage.write(key: _kLanguageKey, value: languageCode);
    } catch (e) {
      // Silently fail if secure storage is not available
      print('Warning: Failed to save language setting: $e');
    }
  }

  @override
  Future<String?> getTheme() async {
    try {
      return await _storage.read(key: _kThemeKey);
    } catch (e) {
      // Return default if secure storage fails
      return null;
    }
  }

  @override
  Future<void> saveTheme(String themeMode) async {
    try {
      await _storage.write(key: _kThemeKey, value: themeMode);
    } catch (e) {
      // Silently fail if secure storage is not available
      print('Warning: Failed to save theme setting: $e');
    }
  }

  @override
  Future<void> saveMapFilter(Set<String> statuses) async {
    try {
      final value = statuses.join(',');
      await _storage.write(key: _kMapFilterKey, value: value);
    } catch (e) {
      // Silently fail if secure storage is not available
      print('Warning: Failed to save map filter setting: $e');
    }
  }

  @override
  Future<Set<String>?> getMapFilter() async {
    try {
      final value = await _storage.read(key: _kMapFilterKey);
      if (value == null || value.isEmpty) return null;
      return value.split(',').toSet();
    } catch (e) {
      // Return default if secure storage fails
      return null;
    }
  }
}
