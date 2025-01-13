import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image/image.dart';

class Annotation implements Comparable {
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

  Annotation deepCopy() {
    return Annotation(
      id: id,
      image: image,
      keyPoints: keyPoints.map((kp) => kp.deepCopy()).toList(),
      clickPoints: clickPoints.map((cp) => cp.deepCopy()).toList(),
      imageLabels: imageLabels.map((il) => il.deepCopy()).toList(),
      bounds: bounds.map((b) => b.deepCopy()).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image.readAsBytes(),
      'key_points': keyPoints.map((kp) => kp.toMap()).toList(),
      'click_points': clickPoints.map((cp) => cp.toMap()).toList(),
      'image_labels': imageLabels.map((il) => il.toMap()).toList(),
      'bounds': bounds.map((b) => b.toMap()).toList(),
    };
  }

  factory Annotation.fromMap(Map<String, dynamic> map, Directory directory) {
    try {
      // バイナリデータをImageオブジェクトにデコード
      final imageBytes = map['image'] as List<int>;
      final image = decodeImage(Uint8List.fromList(imageBytes));

      if (image == null) {
        throw Exception("Image decoding failed");
      }

      // 画像をPNG形式にエンコード
      final pngBytes = encodePng(image);

      // PNGファイルを指定のディレクトリに保存
      final imageFile = File('${directory.path}/image_${map['id']}.png')
        ..writeAsBytesSync(pngBytes);

      return Annotation(
        id: map['id'] as int,
        image: imageFile,
        keyPoints: List<Map<String, dynamic>>.from(map['key_points'] ?? [])
            .map((kp) => KeyPoint.fromMap(kp))
            .toList(),
        clickPoints: List<Map<String, dynamic>>.from(map['click_points'] ?? [])
            .map((cp) => ClickPoint.fromMap(cp))
            .toList(),
        imageLabels: List<Map<String, dynamic>>.from(map['image_labels'] ?? [])
            .map((il) => Label.fromMap(il))
            .toList(),
        bounds: List<Map<String, dynamic>>.from(map['bounds'] ?? [])
            .map((b) => Bound.fromMap(b))
            .toList(),
      );
    } catch (e) {
      rethrow; // エラーハンドリングを強化
    }
  }

  @override
  int compareTo(covariant Annotation other) {
    return id.compareTo(other.id);
  }
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

class KeyPoint implements Comparable<KeyPoint> {
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

  KeyPoint deepCopy() {
    return KeyPoint(
      id: id,
      position: position,
      bodyPart: bodyPart,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'position': {'dx': position.dx, 'dy': position.dy},
      'body_part': bodyPart.index,
    };
  }

  factory KeyPoint.fromMap(Map<String, dynamic> map) {
    return KeyPoint(
      id: map['id'] as int,
      position: Offset(
        map['x'] as double,
        map['y'] as double,
      ),
      bodyPart: BodyPart.values[map['body_part'] as int],
    );
  }

  @override
  int compareTo(KeyPoint other) {
    return id.compareTo(other.id);
  }
}

class ClickPoint implements Comparable<ClickPoint> {
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

  ClickPoint deepCopy() {
    return ClickPoint(
      id: id,
      position: position,
      radius: radius,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'y': position.dy,
      'x': position.dx,
      'radius': radius,
    };
  }

  factory ClickPoint.fromMap(Map<String, dynamic>? map) {
    return ClickPoint(
      id: map?['id'] as int,
      position: Offset(
        0,
        0,
      ),
      radius: map?['radius'] as double,
    );
  }

  @override
  int compareTo(ClickPoint other) {
    return id.compareTo(other.id);
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

  Label deepCopy() {
    return Label(
      id: id,
      name: name,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
    };
  }

  factory Label.fromMap(Map<String, dynamic> map) {
    return Label(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }
}

class Bound {
  final int id;
  final Offset start;
  final Offset end;
  final Label? label;

  Bound({
    required this.start,
    required this.end,
    required this.id,
    this.label,
  });

  Bound copyWith({
    int? id,
    Offset? start,
    Offset? end,
    Label? label,
  }) {
    return Bound(
      id: id ?? this.id,
      start: start ?? this.start,
      end: end ?? this.end,
      label: label ?? this.label,
    );
  }

  Bound deepCopy() {
    return Bound(
      id: id,
      label: label?.deepCopy(),
      start: start,
      end: end,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "start_x": start.dx,
      "start_y": start.dy,
      "end_x": end.dx,
      "end_y": end.dy,
      "label": label?.toMap(),
    };
  }

  factory Bound.fromMap(Map<String, dynamic> map) {
    return Bound(
      id: map['id'] as int,
      start: Offset(
        map['start_x'] as double,
        map['start_y'] as double,
      ),
      end: Offset(
        map['end_x'] as double,
        map['end_y'] as double,
      ),
      label: map['label'] != null
          ? Label.fromMap(map['label'] as Map<String, dynamic>)
          : null,
    );
  }
}

class Metadata {
  final String projectName;
  final String author;
  final String license;
  final List<Label> projectLabels;

  const Metadata({
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

  Metadata deepCopy() {
    return Metadata(
      projectName: projectName,
      author: author,
      license: license,
      projectLabels: projectLabels.map((pl) => pl.deepCopy()).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "project_name": projectName,
      "author": author,
      "licence": license,
    };
  }

  factory Metadata.fromMap(Map<String, dynamic> map) {
    return Metadata(
      projectName: map['project_name'] as String? ?? "undefined",
      author: map['author'] as String? ?? "",
      license: map['licence'] as String? ?? "MIT",
      projectLabels: (map['project_labels'] as List<dynamic>? ?? [])
          .map((label) => Label(
                id: label['id'] as int,
                name: label['name'] as String,
              ))
          .toList(),
    );
  }

  factory Metadata.fromLabelsList(
    List<String> labels, {
    String projectName = "undefined",
    String author = "",
    String license = "MIT",
  }) {
    return Metadata(
      projectName: projectName,
      author: author,
      license: license,
      projectLabels: labels
          .asMap()
          .entries
          .map((entry) => Label(id: entry.key, name: entry.value))
          .toList(),
    );
  }
}

class BubbleViewConstraints {
  final int clickLimit;
  final double bubbleRadius;
  final double blurAmount;

  const BubbleViewConstraints({
    this.bubbleRadius = 30,
    this.clickLimit = 30,
    this.blurAmount = 10,
  });

  BubbleViewConstraints copyWith({
    int? clickLimit,
    double? bubbleRadius,
    double? blurAmount,
  }) {
    return BubbleViewConstraints(
      clickLimit: clickLimit ?? this.clickLimit,
      bubbleRadius: bubbleRadius ?? this.bubbleRadius,
      blurAmount: blurAmount ?? this.blurAmount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "click_limit": clickLimit,
      "bubble_radius": bubbleRadius,
      "blur_amount": blurAmount,
    };
  }

  factory BubbleViewConstraints.fromMap(Map<String, dynamic> map) {
    return BubbleViewConstraints(
      clickLimit: map['click_limit'] as int? ?? 30,
      bubbleRadius: map['bubble_radius'] as double? ?? 30.0,
      blurAmount: map['blur_amount'] as double? ?? 10.0,
    );
  }

  BubbleViewConstraints deepCopy() {
    return BubbleViewConstraints(
      clickLimit: clickLimit,
      bubbleRadius: bubbleRadius,
    );
  }
}

class Project {
  final Metadata metaData;
  final List<Annotation> annotations;
  final BubbleViewConstraints bubbleViewConstraints;

  Project({
    this.metaData = const Metadata(),
    this.annotations = const [],
    this.bubbleViewConstraints = const BubbleViewConstraints(),
  });

  Project.fromImages(
    List<File> images, {
    this.metaData = const Metadata(),
    this.bubbleViewConstraints = const BubbleViewConstraints(),
  }) : annotations = images
            .asMap()
            .entries
            .map((image) => Annotation(id: image.key, image: image.value))
            .toList();

  Map<String, Object> toMap() {
    return {
      "metaData": metaData.toMap(),
      "bubble_view_constraints": bubbleViewConstraints.toMap(),
      "annotations": annotations.map((e) => e.toMap()).toList(),
    };
  }

  Project copyWith({
    Metadata? metaData,
    List<Annotation>? annotations,
    BubbleViewConstraints? bubbleViewConstraints,
  }) {
    return Project(
      metaData: metaData ?? this.metaData,
      annotations: annotations ?? [...this.annotations],
      bubbleViewConstraints:
          bubbleViewConstraints ?? this.bubbleViewConstraints,
    );
  }

  Project deepCopy() {
    return Project(
      metaData: metaData.deepCopy(),
      annotations: [...annotations],
      bubbleViewConstraints: bubbleViewConstraints.deepCopy(),
    );
  }
}
