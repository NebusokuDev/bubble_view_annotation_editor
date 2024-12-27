import 'package:bubble_view_annotation_editor/pages/editor_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AnnotationApp extends StatelessWidget {
  const AnnotationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: GoRouter(routes: [
        GoRoute(path: "/", builder: (context, state) => EditorPage())
      ]),
      title: 'saliency annotator',
      theme: ThemeData.light()
    );
  }
}