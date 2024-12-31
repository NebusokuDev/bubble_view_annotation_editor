import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ImageViewer extends StatefulWidget {
  const ImageViewer({super.key});

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  List<File> _images = [];
  int _currentIndex = 0;
  int x = 0;

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

  void _nextImage() {
    setState(() => _currentIndex = (_currentIndex + 1) % _images.length);
  }

  void _previousImage() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.folder_open),
            onPressed: _pickFolder,
          ),
        ],
      ),
      body: Center(
        child: _images.isEmpty
            ? Text('フォルダを選択してください', style: TextStyle(fontSize: 18))
            : Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 120),
                    child: Column(
                      children: [
                        Text('${_currentIndex + 1} / ${_images.length}'),
                        Expanded(
                          child: Image.file(_images[_currentIndex]),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment(-0.95, 0),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: _previousImage,
                    ),
                  ),
                  Align(
                    alignment: Alignment(0.95, 0),
                    child: IconButton.outlined(
                      icon: Icon(Icons.arrow_forward),
                      onPressed: _nextImage,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
