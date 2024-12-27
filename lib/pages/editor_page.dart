import 'dart:ui';

import 'package:flutter/material.dart';

class EditorPage extends StatelessWidget {
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: BlurImage(onTap: () {}));
  }
}

class BlurImage extends StatelessWidget {
  const BlurImage({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image(image: NetworkImage("https://picsum.photos/200/300")),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(),
        ),
        GestureDetector()
      ],
    );
  }
}
