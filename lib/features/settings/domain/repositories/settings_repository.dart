abstract class SettingsRepository {
  Future<void> saveLanguage(String languageCode);
  Future<String?> getLanguage();
  Future<void> saveTheme(String themeMode);
  Future<String?> getTheme();
  Future<void> saveMapFilter(Set<String> statuses);
  Future<Set<String>?> getMapFilter();
}
