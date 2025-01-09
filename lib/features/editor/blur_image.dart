import 'dart:io';
import 'dart:ui';

import 'package:bubble_view_annotation_editor/features/editor/clip_image.dart';
import 'package:flutter/material.dart';

class BlurImage extends StatelessWidget {
  BlurImage({
    super.key,
    required this.image,
    required this.onTapDown,
    this.clipPos,
    enableBlur,
    blurAmount,
  }) {
    this.blurAmount = blurAmount ?? 10;
    this.enableBlur = enableBlur ?? true;
  }

  final File image;
  late final bool enableBlur;
  late final double blurAmount;
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
        IgnorePointer(
          child: Align(
            alignment: Alignment.center,
            widthFactor: 1.0,
            heightFactor: 1.0,
            child: Transform.scale(
              scale: 1.05,
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
            child: ClipOut(
              localPosition: clipPos!,
              radius: 50,
              child: Image.file(image),
            ),
          )
      ],
    );
  }
}
