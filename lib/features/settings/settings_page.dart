import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLanguage = 'English';
  ThemeMode _themeMode = ThemeMode.system;
  int _maxClicks = 10;
  double _circleRange = 50.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Language setting
            ListTile(
              title: Text('Language'),
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedLanguage = newValue;
                    });
                  }
                },
                items: ['English', 'Japanese', 'Spanish', 'French']
                    .map((String language) {
                  return DropdownMenuItem<String>(
                    value: language,
                    child: Text(language),
                  );
                }).toList(),
              ),
            ),
            // Theme setting
            ListTile(
              title: Text('Theme'),
              trailing: DropdownButton<ThemeMode>(
                value: _themeMode,
                onChanged: (ThemeMode? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _themeMode = newValue;
                    });
                  }
                },
                items: [
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Light Mode'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Dark Mode'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('Auto'),
                  ),
                ],
              ),
            ),
            // Max clicks setting
            ListTile(
              title: Text('Max Clicks'),
              subtitle: Slider(
                value: _maxClicks.toDouble(),
                min: 1,
                max: 100,
                divisions: 99,
                label: _maxClicks.toString(),
                onChanged: (double newValue) {
                  setState(() {
                    _maxClicks = newValue.toInt();
                  });
                },
              ),
            ),
            // Circle range setting
            ListTile(
              title: Text('Circle Range'),
              subtitle: Slider(
                value: _circleRange,
                min: 10.0,
                max: 200.0,
                divisions: 190,
                label: _circleRange.toStringAsFixed(1),
                onChanged: (double newValue) {
                  setState(() {
                    _circleRange = newValue;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
