import 'dart:io';
import 'dart:ui';

import 'package:bubble_view_annotation_editor/components/responsive_layout.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  List<File> _images = [];
  int _currentIndex = 0;

  Future<void> _pickFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      final dir = Directory(selectedDirectory);
      final files = dir
          .listSync()
          .where((item) => item is File && _isImageFile(item.path))
          .map((item) => File(item.path))
          .toList();
      setState(() {
        _images = files;
        _currentIndex = 0;
      });
    }
  }

  bool _isImageFile(String path) {
    final extensions = ['jpg', 'jpeg', 'png', 'bmp', 'gif'];
    final ext = path.split('.').last.toLowerCase();
    return extensions.contains(ext);
  }

  void _changeImage(int offset) {
    _currentIndex = (_currentIndex + offset + _images.length) % _images.length;
  }

  void _nextImage() {
    setState(() => _changeImage(1));
  }

  void _previousImage() {
    setState(() => _changeImage(-1));
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(layouts: {
      0: Scaffold(
        appBar: EditorAppBar(
          onFolderOpen: _pickFolder,
          onSave: () {},
        ),
        drawer: Drawer(
          child: ToolPallet(),
        ),
        body: EditorBody(
          onFolderOpen: _pickFolder,
          currentIndex: _currentIndex,
          images: _images,
          onNextImage: _nextImage,
          onPrevImage: _previousImage,
        ),
      ),
      1100: Scaffold(
        appBar: EditorAppBar(
          onFolderOpen: _pickFolder,
          onSave: () {},
        ),
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
                  onFolderOpen: _pickFolder,
                  currentIndex: _currentIndex,
                  images: _images,
                  onNextImage: _nextImage,
                  onPrevImage: _previousImage,
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
  const EditorAppBar({
    super.key,
    required this.onFolderOpen,
    required this.onSave,
  });

  final VoidCallback onFolderOpen;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        IconButton(onPressed: onFolderOpen, icon: Icon(Icons.folder)),
        IconButton(onPressed: onSave, icon: Icon(Icons.save)),
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
  const EditorBody({
    super.key,
    required this.onFolderOpen,
    required this.currentIndex,
    required this.images,
    required this.onNextImage,
    required this.onPrevImage,
  });

  final List<File> images;
  final int currentIndex;
  final VoidCallback onFolderOpen;
  final VoidCallback onNextImage;
  final VoidCallback onPrevImage;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return GestureDetector(
        onTap: onFolderOpen,
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: Text("画像がありません。画面をクリックするか、フォルダーボタンから画像を追加してください。"),
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              Container(
                margin: EdgeInsets.all(20),
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: GestureDetector(
                    child: Image.file(
                      images[currentIndex],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(-0.975, 0),
                child: IconButton.outlined(
                  onPressed: onPrevImage,
                  icon: Icon(Icons.arrow_left),
                ),
              ),
              Align(
                alignment: Alignment(0.975, 0),
                child: IconButton.outlined(
                  onPressed: onNextImage,
                  icon: Icon(Icons.arrow_right),
                ),
              ),
            ],
          ),
        ),
        Text("${currentIndex + 1} / ${images.length}"),
      ],
    );
  }
}
