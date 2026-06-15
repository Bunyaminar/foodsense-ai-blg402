import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'selected_theme';
  static const String _darkModeKey = 'dark_mode';
  static const String _languageKey = 'language';

  Color _primaryColor = const Color(0xFF2E7D32);
  bool _isDarkMode = false;
  String _language = 'Turkce';

  Color get primaryColor => _primaryColor;
  bool get isDarkMode => _isDarkMode;
  String get language => _language;

  final Map<String, Color> themeColors = {
    'Yesil': const Color(0xFF2E7D32),
    'Mavi': const Color(0xFF1565C0),
    'Mor': const Color(0xFF6A1B9A),
    'Turuncu': const Color(0xFFE65100),
    'Kirmizi': const Color(0xFFB71C1C),
  };

  String get selectedThemeName {
    return themeColors.entries
        .firstWhere((e) => e.value == _primaryColor,
            orElse: () => themeColors.entries.first)
        .key;
  }

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_themeKey) ?? 'Yesil';
    _primaryColor = themeColors[themeName] ?? const Color(0xFF2E7D32);
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    _language = prefs.getString(_languageKey) ?? 'Turkce';
    notifyListeners();
  }

  Future<void> setTheme(String themeName) async {
    _primaryColor = themeColors[themeName] ?? const Color(0xFF2E7D32);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeName);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, lang);
    notifyListeners();
  }

  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: _primaryColor),
    primaryColor: _primaryColor,
  );

  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor, brightness: Brightness.dark),
    primaryColor: _primaryColor,
  );
}