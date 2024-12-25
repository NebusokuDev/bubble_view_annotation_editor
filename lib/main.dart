import 'package:flutter/material.dart';

void main() {
  runApp(const AnnotationApp());
}

class AnnotationApp extends StatelessWidget {
  const AnnotationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}