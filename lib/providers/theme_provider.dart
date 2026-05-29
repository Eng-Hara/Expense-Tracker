import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider =
StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false);

  static const String _themeKey = 'dark_mode';

  // Load saved theme
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    final isDark = prefs.getBool(_themeKey) ?? false;

    state = isDark;
  }

  // Toggle theme
  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();

    state = !state;

    await prefs.setBool(_themeKey, state);
  }

  // Set manually
  Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();

    state = isDark;

    await prefs.setBool(_themeKey, isDark);
  }
}