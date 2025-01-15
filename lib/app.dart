import 'package:bubble_view_annotation_editor/core/settings.dart';
import 'package:bubble_view_annotation_editor/features/editor/editor_page.dart';
import 'package:bubble_view_annotation_editor/features/settings/settings_page.dart';
import 'package:bubble_view_annotation_editor/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AnnotationApp extends ConsumerWidget {
  const AnnotationApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'open image annotator',
      theme: Brightness.light.theme(context),
      darkTheme: Brightness.dark.theme(context),
      themeMode: settings.themeMode,
      routerConfig: appRouter,
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
