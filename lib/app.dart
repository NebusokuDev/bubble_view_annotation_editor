import 'package:bubble_view_annotation_editor/features/editor/editor_page.dart';
import 'package:bubble_view_annotation_editor/features/settings/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AnnotationApp extends StatelessWidget {
  const AnnotationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'open image annotator',
        theme: Brightness.light.theme(),
        darkTheme: Brightness.dark.theme(),
        routerConfig: appRouter);
  }
}

extension on Brightness {
  ThemeData theme({Color seedColor = Colors.indigoAccent}) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: this,
      ),
      useMaterial3: true,
    );
  }
}

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(path: "/", builder: (context, state) => EditorPage()),
    GoRoute(path: "/settings", builder: (context, state) => SettingsPage()),
  ],
);
