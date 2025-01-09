import 'dart:io';
import 'dart:ui';

import 'package:sqflite/sqflite.dart';

class AnnotationData {
  final int id;
  final File image;
  final List<Offset> keyPoints = [];
  final List<Offset> clickPoints = [];
  final List<Label> labels = [];
  final List<Bound> bounds = [];

  AnnotationData({
    required this.id,
    required this.image,
  });
}

class KeyPoints {
  final int id;
  final Offset position;

  KeyPoints({required this.id, required this.position});
}

class ClickPoints {
  final int id;
  final Offset position;

  ClickPoints({required this.id, required this.position});
}

class Label {
  final int id;
  final String name;

  Label({required this.id, required this.name});
}

class Bound {
  final int id;
  final List<Offset> path;
  final Label? label;

  Bound({required this.id, this.label, List<Offset>? path}) : path = path ?? [];
}

class Project {
  late String path;
  late String name;

  int saliencyClickLimit = 30;
  double bubbleRadius = 50;
  double blurAmount = 10;

  late final Database database;

  final List<Label> labels = [];
  final List<AnnotationData> annotations = [];

  Project({String? name}) {
    this.name = name ?? "undefined";
  }

  void update(AnnotationData annotationData) {
    final index = annotations.indexWhere((e) => e.id == annotationData.id);
    if (index != -1) {
      annotations[index] = annotationData;
      return;
    }

    annotations.add(annotationData);
  }

  void createAnnotation({required File image}) {
    final newId = annotations.isEmpty
        ? 1
        : annotations.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;

    final annotationData = AnnotationData(image: image, id: newId);
    annotations.add(annotationData);
  }

  void setBlurAmount(double amount) {
    if (amount.isNegative) return;
    blurAmount = amount;
  }

  void addLabel(String name) {
    final id = labels.length + 1;
    labels.add(Label(id: id, name: name));
  }

  void setBubbleRadius(double radius) {
    if (radius.isNegative) return;
    bubbleRadius = radius;
  }

  void removeLabelAt(int id) {
    labels.removeWhere((label) => label.id == id);
  }
}
