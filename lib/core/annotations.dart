import 'dart:io';

import 'package:flutter/cupertino.dart';

class Annotation {
  final int id;
  File image;
  List<KeyPoint> keyPoints;
  List<ClickPoint> clickPoints;
  List<Label> imageLabels;
  List<Bound> bounds;

  Annotation({
    required this.id,
    required this.image,
    this.imageLabels = const [],
    this.bounds = const [],
    this.clickPoints = const [],
    this.keyPoints = const [],
  });

  Annotation copyWith({
    int? id,
    File? image,
    List<KeyPoint>? keyPoints,
    List<ClickPoint>? clickPoints,
    List<Label>? imageLabels,
    List<Bound>? bounds,
  }) {
    return Annotation(
      id: id ?? this.id,
      image: image ?? this.image,
      keyPoints: keyPoints ?? [...this.keyPoints],
      clickPoints: clickPoints ?? [...this.clickPoints],
      imageLabels: imageLabels ?? [...this.imageLabels],
      bounds: bounds ?? [...this.bounds],
    );
  }
}

class Dataset {
  List<Annotation> annotations;

  Dataset({this.annotations = const []});

  bool get isEmpty => annotations.isEmpty;
}

enum BodyPart {
  nose,
  eyeL,
  eyeR,
  earL,
  earR,
  shoulderL,
  shoulderR,
  elbowL,
  elbowR,
  wristL,
  wristR,
  hipL,
  hipR,
  kneeL,
  kneeR,
  ankleL,
  ankleR,
}

class KeyPoint {
  final int id;
  final Offset position;
  final BodyPart bodyPart;

  KeyPoint({required this.id, required this.position, required this.bodyPart});

  KeyPoint copyWith({
    int? id,
    Offset? position,
    BodyPart? bodyPart,
  }) {
    return KeyPoint(
      id: id ?? this.id,
      position: position ?? this.position,
      bodyPart: bodyPart ?? this.bodyPart,
    );
  }
}

class ClickPoint {
  final int id;
  final Offset position;
  final double radius;

  ClickPoint({required this.id, required this.position, required this.radius});

  ClickPoint copyWith({
    int? id,
    Offset? position,
    double? radius,
  }) {
    return ClickPoint(
      id: id ?? this.id,
      position: position ?? this.position,
      radius: radius ?? this.radius,
    );
  }
}

class Label {
  final int id;
  final String name;

  Label({required this.id, required this.name});

  Label copyWith({
    int? id,
    String? name,
  }) {
    return Label(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}

class Bound {
  final int id;
  final List<Offset> path;
  final Label? label;

  Bound({required this.id, this.label, List<Offset>? path}) : path = path ?? [];

  Bound copyWith({
    int? id,
    List<Offset>? path,
    Label? label,
  }) {
    return Bound(
      id: id ?? this.id,
      path: path ?? [...this.path],
      label: label ?? this.label,
    );
  }
}

class Metadata {
  String projectName;
  String author;
  String license;
  List<Label> projectLabels;

  Metadata({
    this.projectName = "undefined",
    this.author = "",
    this.license = "MIT",
    this.projectLabels = const [],
  });

  Metadata copyWith({
    String? projectName,
    String? author,
    String? license,
    List<Label>? projectLabels,
  }) {
    return Metadata(
      projectName: projectName ?? this.projectName,
      author: author ?? this.author,
      license: license ?? this.license,
      projectLabels: projectLabels ?? [...this.projectLabels],
    );
  }
}

class BubbleViewConstraints {
  late int saliencyClickLimit;
  late double bubbleRadius;

  BubbleViewConstraints({
    this.bubbleRadius = 30,
    this.saliencyClickLimit = 30,
  });

  BubbleViewConstraints copyWith({
    int? saliencyClickLimit,
    double? bubbleRadius,
  }) {
    return BubbleViewConstraints(
      saliencyClickLimit: saliencyClickLimit ?? this.saliencyClickLimit,
      bubbleRadius: bubbleRadius ?? this.bubbleRadius,
    );
  }
}

class Project {
  late final Metadata metaData;
  late Dataset dataset;
  late BubbleViewConstraints bubbleViewConstraints;

  Project({
    Metadata? metaData,
    Dataset? dataset,
    BubbleViewConstraints? bubbleViewConstraints,
  }) {
    this.metaData = metaData ?? Metadata();
    this.dataset = dataset ?? Dataset();
    this.bubbleViewConstraints =
        bubbleViewConstraints ?? BubbleViewConstraints();
  }

  Project.fromImages(List<File> images) {
    if (images.isEmpty) {
      dataset = Dataset();
      return;
    }

    List<Annotation> annotations = images.map((image) {
      int id = images.indexOf(image);
      return Annotation(
        id: id,
        image: image,
      );
    }).toList();

    dataset = Dataset(annotations: annotations);
  }

  Project.fromMap({
    Map<String, Object>? metadata,
    Map<String, Object>? bubbleViewConstraints,
    Map<String, Object>? dataset,
  });

  List<Map<String, Object>> toMap() {
    return [];
  }

  Project copyWith({
    Metadata? metaData,
    Dataset? dataset,
    BubbleViewConstraints? bubbleViewConstraints,
  }) {
    return Project(
      metaData: metaData ?? this.metaData,
      dataset: dataset ?? this.dataset,
      bubbleViewConstraints:
          bubbleViewConstraints ?? this.bubbleViewConstraints,
    );
  }
}
