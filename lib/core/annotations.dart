import 'dart:io';
import 'dart:ui';

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
  late String name;

  final List<Label> labels = [];
  final List<AnnotationData> annotations = [];

  Project({String? name}) {
    this.name = name ?? "undefined";
  }
}
