import 'dart:io';

import 'package:bubble_view_annotation_editor/components/responsive_layout.dart';
import 'package:flutter/material.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  List<File> _images = [];

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(layouts: {
      0: Scaffold(
        appBar: EditorAppBar(),
        drawer: Drawer(),
        body: EditorBody(
          images: _images,
        ),
      ),
      1100: Scaffold(
        appBar: EditorAppBar(),
        body: Row(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              margin: EdgeInsets.zero,
              elevation: 5,
              child: SizedBox(
                width: 300,
                child: ToolPallet(),
              ),
            ),
            Expanded(
              flex: 8,
              child: Container(
                color: Colors.black12,
                child: EditorBody(
                  images: _images,
                ),
              ),
            )
          ],
        ),
      ),
    });
  }
}

class EditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EditorAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        IconButton(onPressed: () {}, icon: Icon(Icons.folder)),
        IconButton(onPressed: () {}, icon: Icon(Icons.save)),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class ToolPallet extends StatelessWidget {
  const ToolPallet({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ExpansionTile(title: Text("aaa")),
        ExpansionTile(title: Text("aaa")),
        ExpansionTile(title: Text("aaa")),
        ExpansionTile(title: Text("aaa")),
      ],
    );
  }
}

class EditorBody extends StatelessWidget {
  const EditorBody({super.key, required this.images});

  final List<File> images;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return GestureDetector(
        onTap: () {
          print("tap!");
        },
        child: Center(
          child: Text("画像がありません。画面をクリックするか、フォルダーボタンから画像を追加してください。"),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Image.network("https://picsum.photos/800/600"),
        Align(
          alignment: Alignment(-0.975, 0),
          child: IconButton.outlined(
            onPressed: () {},
            icon: Icon(Icons.arrow_left),
          ),
        ),
        Align(
          alignment: Alignment(0.975, 0),
          child: IconButton.outlined(
            onPressed: () {},
            icon: Icon(Icons.arrow_right),
          ),
        ),
      ],
    );
  }
}
