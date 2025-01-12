import 'dart:io';
import 'dart:ui';

import 'package:bubble_view_annotation_editor/features/editor/clipping.dart';
import 'package:flutter/material.dart';

class BubbleView extends StatelessWidget {
  const BubbleView({
    super.key,
    required this.image,
    required this.onTapDown,
    this.clipPos,
    this.enableBlur = true,
    this.blurAmount = 10,
    this.bubbleRadius = 50,
  });

  final File image;
  final bool enableBlur;
  final double blurAmount;
  final double bubbleRadius;
  final Offset? clipPos;

  final void Function(TapDownDetails) onTapDown;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTapDown: onTapDown,
          child: Image.file(image),
        ),
        if (enableBlur)
          IgnorePointer(
            child: Align(
              alignment: Alignment.center,
              widthFactor: 1.0,
              heightFactor: 1.0,
              child: Transform.scale(
                scale: 1,
                child: ImageFiltered(
                  imageFilter:
                      ImageFilter.blur(sigmaY: blurAmount, sigmaX: blurAmount),
                  child: Image.file(image),
                ),
              ),
            ),
          ),
        if (clipPos != null)
          IgnorePointer(
            child: Clipping(
              localPosition: clipPos!,
              radius: bubbleRadius,
              child: Image.file(image),
            ),
          )
      ],
    );
  }
}
