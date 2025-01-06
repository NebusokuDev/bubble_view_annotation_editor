import 'dart:io';
import 'dart:ui';

import 'package:bubble_view_annotation_editor/features/editor/clip_image.dart';
import 'package:flutter/material.dart';

class BlurImage extends StatefulWidget {
  BlurImage({
    super.key,
    required this.image,
    required this.onTapDown,
    enableBlur,
    blurAmount,
  }) {
    this.blurAmount = blurAmount ?? 10;
    this.enableBlur = enableBlur ?? true;
  }

  final File image;
  late final bool enableBlur;
  late final double blurAmount;

  final void Function(TapDownDetails) onTapDown;

  @override
  State<BlurImage> createState() => _BlurImageState();
}

class _BlurImageState extends State<BlurImage> {
  Offset? clipPos = Offset(0, 0);

  void onTapDown(TapDownDetails details) {
    widget.onTapDown(details);
    setState(() {
      clipPos = details.localPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTapDown: onTapDown,
          child: Image.file(widget.image),
        ),
        IgnorePointer(
          child: Align(
            alignment: Alignment.center,
            widthFactor: 1.0,
            heightFactor: 1.0,
            child: Transform.scale(
              scale: 1.05,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                    sigmaY: widget.blurAmount, sigmaX: widget.blurAmount),
                child: Image.file(widget.image),
              ),
            ),
          ),
        ),
        if (clipPos != null)
          IgnorePointer(
            child: ClipOut(
              localPosition: clipPos!,
              radius: 50,
              child: Image.file(widget.image),
            ),
          )
      ],
    );
  }
}
