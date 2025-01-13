import 'package:bubble_view_annotation_editor/core/settings.dart';
import 'package:bubble_view_annotation_editor/features/editor/editor_page.dart';
import 'package:bubble_view_annotation_editor/features/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AnnotationApp extends ConsumerWidget {
  const AnnotationApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'open image annotator',
      theme: Brightness.light.theme(context: context),
      darkTheme: Brightness.dark.theme(context: context),
      themeMode: settings.themeMode,
      routerConfig: appRouter,
    );
  }
}

extension on Brightness {
  ThemeData theme(
      {BuildContext? context, Color seedColor = Colors.indigoAccent}) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: this,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.notoSansJpTextTheme(
        context != null ? Theme.of(context).textTheme : null,
      ),
    );
  }
}

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(path: "/", builder: (context, state) => EditorPage()),
    GoRoute(path: "/editor", builder: (context, state) => EditorPage()),
    GoRoute(path: "/settings", builder: (context, state) => SettingsPage()),
  ],
);
