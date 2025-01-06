import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

class BlurImage extends StatelessWidget {
  BlurImage({
    super.key,
    required this.image,
    required this.onTap,
    enableBlur,
    blurAmount,
  }) {
    this.blurAmount = blurAmount ?? 10;
    this.enableBlur = enableBlur ?? true;
  }

  final File image;
  late final bool enableBlur;
  late final double blurAmount;

  final void Function(TapDownDetails) onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTapDown: onTap,
          child: Image.file(image),
        ),
        if (enableBlur)
          IgnorePointer(
            child: ClipRect(
              child: Align(
                alignment: Alignment.center,
                widthFactor: 1.0,
                heightFactor: 1.0,
                child: Transform.scale(
                  scale: 1.05,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(
                        sigmaY: blurAmount, sigmaX: blurAmount),
                    child: Image.file(image),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
