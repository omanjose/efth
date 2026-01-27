
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs => _preferences!;

  // Theme
  static const String _themeKey = 'theme_mode';

  static Future<void> setThemeMode(String mode) async {
    await prefs.setString(_themeKey, mode);
  }

  static String getThemeMode() {
    return prefs.getString(_themeKey) ?? 'system';
  }

  // Font Size
  static const String _fontSizeKey = 'font_size';

  static Future<void> setFontSize(double size) async {
    await prefs.setDouble(_fontSizeKey, size);
  }

  static double getFontSize() {
    return prefs.getDouble(_fontSizeKey) ?? 16.0;
  }

  // Language
  static const String _languageKey = 'selected_language';

  static Future<void> setLanguage(String language) async {
    await prefs.setString(_languageKey, language);
  }

  static String getLanguage() {
    return prefs.getString(_languageKey) ?? 'English';
  }
}