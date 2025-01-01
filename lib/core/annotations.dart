import 'dart:io';
import 'dart:ui';

class AnnotationData {
  final File image;
  final List<Offset>? bubbleViewClickPoints;

  AnnotationData({
    required this.image,
    this.bubbleViewClickPoints,
  });
}
