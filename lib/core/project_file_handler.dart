import 'package:bubble_view_annotation_editor/core/annotations.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

abstract class ProjectFileHandler {
  Future<Project> open(String path);

  Future<void> save(Project project, String path);
}

class SQLiteProjectFileHandler implements ProjectFileHandler {
  @override
  Future<Project> open(String path) async {
    final db = await openProjectDatabase(path);

    return Project.fromMap();
  }

  @override
  Future<void> save(Project project, String path) async {
    final db = await openProjectDatabase(path);
  }
}

Future<Database> openProjectDatabase(String path) async {
  return await openDatabase(path, onCreate: (db, version) async {
    final sql = await rootBundle.loadString("assets/sql/create_table.sql");

    db.execute(sql);
  });
}
