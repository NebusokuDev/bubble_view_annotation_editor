import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'app.dart';

void main() {
  setupDatabase();

  runApp(ProviderScope(child: const AnnotationApp()));
}

void setupDatabase() {
  sqfliteFfiInit();
  databaseFactory = getDatabaseFactory();
}

DatabaseFactory getDatabaseFactory() {
  return switch (defaultTargetPlatform) {
    _ when kIsWeb => databaseFactoryFfiWeb,
    TargetPlatform.android || TargetPlatform.iOS => databaseFactory,
    TargetPlatform.linux ||
    TargetPlatform.macOS ||
    TargetPlatform.windows =>
      databaseFactoryFfi,
    _ => throw UnsupportedError("this device is Unsupported!"),
  };
}
