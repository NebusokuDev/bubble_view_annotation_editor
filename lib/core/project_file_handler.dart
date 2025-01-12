import 'package:bubble_view_annotation_editor/core/annotations.dart';
import 'package:sqflite/sqflite.dart';

abstract class ProjectFileHandler {
  Future<Project> open(String path);

  Future<void> save(Project project, String path);
}

class SQLiteProjectFileHandler implements ProjectFileHandler {
  Future<Database> _openDatabase(String path) async {
    return await openDatabase(path, onCreate: (db, version) async {});
  }

  @override
  Future<Project> open(String path) {
    // TODO: implement open
    throw UnimplementedError();
  }

  @override
  Future<void> save(Project project, String path) {
    // TODO: implement save
    throw UnimplementedError();
  }
}
