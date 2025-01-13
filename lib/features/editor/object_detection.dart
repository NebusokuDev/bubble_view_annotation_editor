import 'dart:io';

import 'package:bubble_view_annotation_editor/features/editor/range_selection.dart';
import 'package:flutter/cupertino.dart';

class ObjectDetection extends StatelessWidget {
  const ObjectDetection({super.key, required this.image});

  final File image;

  @override
  Widget build(BuildContext context) {
    return RangeSelection(
      onBoundsChanged: (Rect bounds) {},
      child: Image.file(image),
    );
  }
}
