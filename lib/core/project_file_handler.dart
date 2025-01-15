import 'dart:io';

import 'package:bubble_view_annotation_editor/core/annotations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

abstract class ProjectFileHandler {
  Future<Project> open(String path);

  Future<void> save(Project project, String path);
}

typedef ProgressCallback = void Function(
  int total,
  int current,
  String? details,
);

class SQLiteProjectFileHandler implements ProjectFileHandler {
  const SQLiteProjectFileHandler();

  @override
  Future<void> save(Project project, String path) async {
    final db = await openProjectDatabase(path);

    await db.transaction((txn) async {
      // プロジェクトの挿入
      final projectId = 1;
      await txn.insert(
        'projects',
        {
          "id": projectId,
          "project_name": project.metaData.projectName,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // メタデータの保存
      await txn.insert(
        'metadata',
        {
          'project_id': projectId,
          ...project.metaData.toMap(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // プロジェクトラベルの保存
      for (final label in project.metaData.projectLabels) {
        await txn.insert(
          'project_labels',
          {
            'project_id': projectId,
            ...label.toMap(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // アノテーションの保存
      for (final annotation in project.annotations) {
        final annotationId = await txn.insert(
          'annotations',
          {
            'project_id': projectId,
            'image': annotation.image.readAsBytesSync(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // KeyPoint の保存
        for (final keyPoint in annotation.keyPoints) {
          await txn.insert(
            'key_points',
            {
              'annotation_id': annotationId,
              'x': keyPoint.position.dx,
              'y': keyPoint.position.dy,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        // ClickPoint の保存
        for (final clickPoint in annotation.clickPoints) {
          await txn.insert(
            'click_points',
            {
              'annotation_id': annotationId,
              'x': clickPoint.position.dx,
              'y': clickPoint.position.dy,
              'radius': clickPoint.radius,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        // ImageLabel の保存
        for (final label in annotation.imageLabels) {
          final labelId = await txn.insert(
            'image_labels',
            {
              'annotation_id': annotationId,
              'name': label.name,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          // BoundingBox の保存
          for (final bound
              in annotation.bounds.where((b) => b.label?.id == label.id)) {
            await txn.insert(
              'bounding_boxes',
              {
                'annotation_id': annotationId,
                'image_label_id': labelId,
                'start_x': bound.start.dx,
                'start_y': bound.start.dy,
                'end_x': bound.end.dx,
                'end_y': bound.end.dy,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      }
      debugPrint('Project saved successfully.');
    });
  }

  @override
  Future<Project> open(String projectFilePath,
      {ProgressCallback? onProgress}) async {
    final db = await openProjectDatabase(projectFilePath);

    // 一時ディレクトリの取得
    final cacheDirectory = await getTemporaryDirectory();

    final results = await Future.wait([
      db.query("projects"),
      db.query('annotations'),
      db.query('bounding_boxes'),
      db.query('click_points'),
      db.query('image_labels'),
      db.query('key_points'),
      db.query('metadata'),
      db.query('project_labels'),
      db.query('bubble_view_constraints'),
    ]);

    final projectRows = results[0];
    final annotationRows = results[1];
    final boundingBoxRows = results[2];
    final clickPointRows = results[3];
    final imageLabelRows = results[4];
    final keyPointRows = results[5];
    final metadataRows = results[6];
    final projectLabelRows = results[7];
    final bubbleViewConstraintsRows = results[8];

    // プロジェクトデータの処理
    final project = projectRows.isNotEmpty ? projectRows.first : null;
    if (project == null) {
      throw Exception("No project found in the database");
    }

    // メタデータの処理
    final metaData = _extractMetadata(metadataRows);

    // バブルビュー制約の処理
    final bubbleViewConstraints =
        _extractConstraints(bubbleViewConstraintsRows);

    // アノテーションの処理
    final annotationList = <Annotation>[];

    final keyPoints = _extractKeyPoints(keyPointRows);
    final clickPoints = _extractClickPoints(clickPointRows);
    final bounds = _extractBounds(boundingBoxRows);
    final imageLabels = _extractImageLabels(imageLabelRows);
    final images = _extractImages(annotationRows, cacheDirectory);

    for (int index = 0; index < annotationRows.length; index++) {
      final annotationRow = annotationRows[index];
      final imageBytes = annotationRow["image"] as List<int>;
      final decodedImage = decodeImage(Uint8List.fromList(imageBytes));

      if (decodedImage == null) continue;

      final annotationId = annotationRow['id'] as int;

      onProgress?.call(annotationRows.length, index + 1, "画像をエンコード...");

      final imageFile = File(join(cacheDirectory.path, "$annotationId.png"));
      imageFile.writeAsBytes(encodePng(decodedImage));

      onProgress?.call(annotationRows.length, index + 1, "キーポイントを解析中...");

      final keyPointsForAnnotation = keyPointRows
          .where((row) => row['annotation_id'] == annotationId)
          .map((row) => KeyPoint.fromMap(row))
          .toList();

      onProgress?.call(annotationRows.length, index + 1, "クリックポイントを解析中...");

      final clickPointsForAnnotation = clickPointRows
          .where((row) => row['annotation_id'] == annotationId)
          .map((row) => ClickPoint.fromMap(row))
          .toList();

      onProgress?.call(annotationRows.length, index + 1, "画像ラベルを解析中...");

      final imageLabelsForAnnotation = imageLabelRows
          .where((row) => row['annotation_id'] == annotationId)
          .map((row) => Label.fromMap(row))
          .toList();

      onProgress?.call(annotationRows.length, index + 1, "バウンディングボックスを解析中...");

      final boundsForAnnotation = boundingBoxRows
          .where((row) => row['annotation_id'] == annotationId)
          .map((row) => Bound.fromMap(row))
          .toList();

      onProgress?.call(annotationRows.length, index + 1, "アノテーションを追加...");

      final annotation = Annotation(
        id: annotationId,
        image: imageFile,
        keyPoints: keyPointsForAnnotation,
        clickPoints: clickPointsForAnnotation,
        imageLabels: imageLabelsForAnnotation,
        bounds: boundsForAnnotation,
      );

      annotationList.add(annotation);
    }

    // プロジェクトラベルの処理
    final projectLabels =
        projectLabelRows.map((row) => Label.fromMap(row)).toList();

    // プロジェクトの作成
    final loadedProject = Project(
      metaData: metaData.copyWith(projectLabels: projectLabels),
      annotations: annotationList,
      bubbleViewConstraints: bubbleViewConstraints,
    );

    return loadedProject;
  }

  Metadata _extractMetadata(List<Map<String, dynamic>> maps) {
    return maps.isNotEmpty ? Metadata.fromMap(maps.first) : Metadata();
  }

  BubbleViewConstraints _extractConstraints(List<Map<String, dynamic>> maps) {
    return maps.isNotEmpty
        ? BubbleViewConstraints.fromMap(maps.first)
        : BubbleViewConstraints();
  }

  List<T> _extractList<T>(List<Map<String, dynamic>> rows,
      T Function(Map<String, dynamic>) fromMap) {
    return rows.map(fromMap).toList();
  }

  List<KeyPoint> _extractKeyPoints(List<Map<String, dynamic>> keyPointsMap) {
    return _extractList(keyPointsMap, KeyPoint.fromMap);
  }

  List<ClickPoint> _extractClickPoints(List<Map<String, dynamic>> clickPoints) {
    return _extractList(clickPoints, ClickPoint.fromMap);
  }

  List<Label> _extractImageLabels(List<Map<String, dynamic>> imageLabels) {
    return _extractList(imageLabels, Label.fromMap);
  }

  List<Bound> _extractBounds(List<Map<String, dynamic>> bounds) {
    return _extractList(bounds, Bound.fromMap);
  }

  List<Map<int, File>> _extractImages(
    List<Map<String, dynamic>> annotationRow,
    Directory cacheDirectory,
  ) {
    return [];
    // final imageBytes = annotationRow["image"] as List<int>;
    // final decodedImage = decodeImage(Uint8List.fromList(imageBytes));
    //
    // if (decodedImage == null) return null;
    //
    // final annotationId = annotationRow['id'] as int;
    //
    // final imageFile = File(join(cacheDirectory.path, "$annotationId.png"));
    // imageFile.writeAsBytes(encodePng(decodedImage));
    // return annotation;
  }
}

Future<Database> openProjectDatabase(String path) async {
  return await openDatabase(
    path,
    version: 1,
    onUpgrade: (db, oldVer, newVer) async {
      final sql = await rootBundle.loadString("assets/sql/create_table.sql");

      db.execute(sql);
    },
    onCreate: (db, version) async {
      final sql = await rootBundle.loadString("assets/sql/create_table.sql");

      db.execute(sql);
    },
  );
}
