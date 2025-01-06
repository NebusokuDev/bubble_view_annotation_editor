import 'dart:convert'; // jsonEncode を使用するため
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

class AnnotationData {
  final int? id;
  final File image;
  final List<Offset> keyPoints = [];
  final List<Offset> bubbleViewClickPoints = [];
  final List<String> label = [];
  final List<Bounding> bounds = [];

  AnnotationData({
    required this.image,
    this.id,
  });

  factory AnnotationData.fromJson(Map<String, dynamic> json) {
    return AnnotationData(
      image: File(json['image'] as String),
      id: json['id'] as int?,
    )
      ..keyPoints.addAll(
          (json['keyPoints'] as List).map((e) => Offset(e['x'], e['y'])))
      ..bubbleViewClickPoints.addAll((json['bubbleViewClickPoints'] as List)
          .map((e) => Offset(e['x'], e['y'])))
      ..label.addAll((json['label'] as List).cast<String>())
      ..bounds
          .addAll((json['bounds'] as List).map((b) => Bounding.fromJson(b)));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image.path,
      'keyPoints': keyPoints.map((e) => {'x': e.dx, 'y': e.dy}).toList(),
      'bubbleViewClickPoints':
          bubbleViewClickPoints.map((e) => {'x': e.dx, 'y': e.dy}).toList(),
      'label': label,
      'bounds': bounds.map((b) => b.toJson()).toList(),
    };
  }
}

class Label {
  final int id;
  final String name;

  Label({required this.id, required this.name});
}

class Bounding {
  final List<Offset> path;

  Bounding({List<Offset>? path}) : path = path ?? [];

  factory Bounding.fromJson(Map<String, dynamic> json) {
    return Bounding(
      path: (json['path'] as List).map((e) => Offset(e['x'], e['y'])).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path.map((e) => {'x': e.dx, 'y': e.dy}).toList(),
    };
  }
}

class Project {
  late String path;
  String name = "undefined";
  final List<String> labels = [];
  final List<AnnotationData> annotations = [];

  Project({required this.path});

  Project.create() {
    path = ":memory:"; // In-memory database
  }

  Future<void> saveAnnotation(AnnotationData annotationData) async {
    final db = await openDB(path);
    if (annotationData.id != null) {
      await db.update(
        'annotations',
        annotationData.toJson(),
        where: 'id = ?',
        whereArgs: [annotationData.id],
      );
    } else {
      await db.insert('annotations', annotationData.toJson());
    }
  }

  Future<void> deleteAnnotation(int id) async {
    final db = await openDB(path);
    await db.delete('annotations', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<AnnotationData>> findAll() async {
    final db = await openDB(path);
    final maps = await db.query('annotations');

    return List.generate(
      maps.length,
      (i) => AnnotationData.fromJson(maps[i]),
    );
  }

  Future<AnnotationData?> findBy(int id) async {
    final db = await openDB(path);
    final maps =
        await db.query('annotations', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return AnnotationData.fromJson(maps.first);
    }
    return null;
  }

  Future<Database> openDB(String path) async {
    if (path == ":memory:") {
      return openDatabase(path);
    }

    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      final sql = await rootBundle.loadString("assets/sql/create.sql");
      await db.execute(sql);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading SQL: $e');
      }
    }
  }

  String toJson() {
    return jsonEncode({
      'path': path,
      'name': name,
      'labels': labels,
      'annotations': annotations.map((e) => e.toJson()).toList(),
    });
  }

  String toCSV() {
    // CSV形式でエクスポートするロジック（簡易実装）
    final buffer = StringBuffer();
    buffer.writeln(
        'id,name,imagePath,keyPoints,bubbleViewClickPoints,label,bounds');

    for (var annotation in annotations) {
      buffer.writeln(
          '${annotation.id ?? "null"},$name,${annotation.image.path},${annotation.keyPoints.map((e) => "(${e.dx},${e.dy})").join(';')},${annotation.bubbleViewClickPoints.map((e) => "(${e.dx},${e.dy})").join(';')},${annotation.label.join(';')},${annotation.bounds.map((b) => b.path.map((p) => "(${p.dx},${p.dy})").join(';')).join(';')}');
    }

    return buffer.toString();
  }

  String toCoco() {
    // COCOフォーマットに合わせたエクスポート（簡易実装）
    final buffer = StringBuffer();
    buffer.writeln('{"images":[{');
    buffer.writeln('"id":"${name}", "path":"$path"}],');

    buffer.writeln('"annotations":[');
    for (var annotation in annotations) {
      buffer.writeln('{');
      buffer.writeln('"id":${annotation.id},');
      buffer.writeln('"image_id":"${annotation.image.path}",');
      buffer.writeln('"keypoints":${annotation.keyPoints.map((e) => [
            e.dx,
            e.dy
          ]).toList()},');
      buffer.writeln('"label":"${annotation.label.join(', ')}",');
      buffer.writeln('"bbox":${annotation.bounds.map((b) => b.path.map((p) => [
            p.dx,
            p.dy
          ]).toList()).toList()}');
      buffer.writeln('},');
    }

    buffer.writeln(']}');
    return buffer.toString();
  }
}
