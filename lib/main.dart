import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app.dart';

void main() {
  if (isDesktop()) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(ProviderScope(child: const AnnotationApp()));
}

bool isDesktop() => [
      TargetPlatform.windows,
      TargetPlatform.linux,
      TargetPlatform.macOS,
    ].contains(defaultTargetPlatform);
