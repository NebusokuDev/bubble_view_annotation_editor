import 'package:bubble_view_annotation_editor/core/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.go("/"),
        ),
        title: Text(
          '設定',
          style: textTheme.headlineSmall,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64),
        child: ListView(
          children: [
            SettingsGroup(
              heading: Text("レイアウト"),
              settings: [
                ListTile(
                  title: Text("テーマモードの切替"),
                  onTap: ref.read(settingsProvider).toggleThemeMode,
                  trailing: Icon(
                    switch (ref.watch(settingsProvider).themeMode) {
                      ThemeMode.system => Icons.brightness_auto_outlined,
                      ThemeMode.light => Icons.light_mode,
                      ThemeMode.dark => Icons.dark_mode,
                    },
                  ),
                ),
                SwitchListTile(
                    title: Text("レイアウトを右にする"), value: true, onChanged: (b) {})
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsGroup extends StatelessWidget {
  final Widget heading;
  final List<Widget> settings;

  const SettingsGroup({
    super.key,
    required this.heading,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: heading,
            ),
            ...settings,
            SizedBox(
              height: 15,
            )
          ],
        ),
      ),
    );
  }
}
