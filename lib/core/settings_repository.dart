import 'package:flutter/material.dart';

class SettingsRepository {
  // Method to save settings
  void save(Settings settings) {
    // TODO: Implement save logic
  }

  // Method to load settings
  Settings load() {
    // TODO: Implement load logic
    return Settings();
  }

  // Method to reset settings to default
  void reset() {
    // TODO: Implement reset logic
  }
}

class Settings {
  // Theme mode: auto, dark, light
  ThemeMode themeMode;

  // Desktop layout: left, right
  ToolbarLayout desktopLayout;

  Settings({
    this.themeMode = ThemeMode.system,
    this.desktopLayout = ToolbarLayout.right,
  });
}

enum ToolbarLayout {
  left,
  right,
}
