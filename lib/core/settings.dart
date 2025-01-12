import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PreferenceKeys { forceTileOpen, themeMode }

class SettingsNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _forceTileOpen = false;

  SettingsNotifier() {
    _loadThemeMode();
    _loadForceTileOpen();
  }

  ThemeMode get themeMode => _themeMode;

  set themeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveThemeMode(mode);
    notifyListeners();
  }

  bool get initialTileOpen => _forceTileOpen;

  set initialTileOpen(bool value) {
    _forceTileOpen = value;
    notifyListeners();
  }

  void toggleThemeMode() {
    themeMode = switch (_themeMode) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
  }

  void toggleInitialTileOpen(bool value) {
    initialTileOpen = value;
    _saveForceTileOpen();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(PreferenceKeys.themeMode.name) ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PreferenceKeys.themeMode.name, mode.index);
  }

  Future<void> _loadForceTileOpen() async {
    final prefs = await SharedPreferences.getInstance();
    initialTileOpen = prefs.getBool(PreferenceKeys.forceTileOpen.name) ?? false;
  }

  Future<void> _saveForceTileOpen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PreferenceKeys.forceTileOpen.name, initialTileOpen);
  }
}

final settingsProvider = ChangeNotifierProvider<SettingsNotifier>(
  (ref) => SettingsNotifier(),
);
