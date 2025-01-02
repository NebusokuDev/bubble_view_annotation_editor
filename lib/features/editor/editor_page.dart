import 'dart:io';

import 'package:bubble_view_annotation_editor/components/editable_title_field.dart';
import 'package:bubble_view_annotation_editor/components/responsive_layout.dart';
import 'package:bubble_view_annotation_editor/core/annotations.dart';
import 'package:bubble_view_annotation_editor/features/editor/blur_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final List<AnnotationData> _annotations = [];
  int _currentIndex = 0;
  int _toolSelectionIndex = 0;

  late TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController(text: "Untitled");
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future _createProject() async {}

  Future _pickProject() async {
    final selectedFile = await FilePicker.platform.pickFiles(
      allowedExtensions: ["anno"],
      type: FileType.custom,
    );
  }

  Future _saveProject() async {
    final selectDirectory = await FilePicker.platform.saveFile(
      fileName: "${_controller.text}.anno",
      allowedExtensions: ["anno"],
      type: FileType.custom,
    );
  }

  Future<void> _pickFolder() async {
    final selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      final dir = Directory(selectedDirectory);
      _addAnnotation(dir
          .listSync()
          .where((item) => item is File && _isImageFile(item.path))
          .map((item) => File(item.path))
          .toList());
    }
  }

  bool _isImageFile(String path) {
    final extensions = ['jpg', 'jpeg', 'png', 'bmp', 'gif'];
    final ext = path.split('.').last.toLowerCase();
    return extensions.contains(ext);
  }

  Future<void> _pickImage() async {
    final results = await FilePicker.platform.pickFiles(
      dialogTitle: "select images",
      type: FileType.image,
      allowMultiple: true,
    );

    _addAnnotation(results?.files.map((f) => File(f.path!)).toList() ?? []);
  }

  void _addAnnotation(List<File>? newImages) {
    if (newImages == null) return;

    setState(() {
      _annotations.addAll(newImages.map((img) => AnnotationData(image: img)));
    });
  }

  void _deleteImage() {
    if (_currentIndex >= 0 && _currentIndex < _annotations.length) {
      setState(() {
        _annotations.removeAt(_currentIndex);

        if (_currentIndex >= _annotations.length && _annotations.isNotEmpty) {
          _currentIndex = _annotations.length - 1;
        } else if (_annotations.isEmpty) {
          _currentIndex = 0;
        }
      });
    }
  }

  void _changeImageAt(int index) => setState(() => _currentIndex = index);

  void _nextImage() {
    final nextIndex =
        (_currentIndex + 1 + _annotations.length) % _annotations.length;

    _changeImageAt(nextIndex);
  }

  void _previousImage() {
    final nextIndex =
        (_currentIndex - 1 + _annotations.length) % _annotations.length;
    _changeImageAt(nextIndex);
  }

  void _onImageTap(TapDownDetails details) {
    print(details.localPosition);
  }

  void _selectTool(int index) {
    setState(() {
      _toolSelectionIndex = index;
      print(index);
    });
  }

  void _redo() {}

  void _undo() {}

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(layouts: {
      0: Scaffold(
        appBar: EditorAppBar(
          onProjectCreate: _createProject,
          onProjectOpen: _pickProject,
          onProjectSave: _saveProject,
          onUndo: _undo,
          onRedo: _redo,
          onSetting: () => context.go("/settings"),
          controller: _controller,
        ),
        drawer: Drawer(
          child: Column(
            children: [
              Expanded(child: Inspector()),
              Expanded(
                flex: 2,
                child: Hierarchy(
                  annotations: _annotations,
                  selectIndex: _currentIndex,
                  onSelection: _changeImageAt,
                  onPickImage: _pickImage,
                  onPickFolder: _pickFolder,
                  onDelete: _deleteImage,
                ),
              ),
            ],
          ),
        ),
        body: Row(
          children: [
            Toolbar(
              toolSelectIndex: _toolSelectionIndex,
              onToolSelected: _selectTool,
            ),
            Expanded(
              flex: 8,
              child: EditorBody(
                onImageOpen: _pickImage,
                currentIndex: _currentIndex,
                annotations: _annotations,
                onNextImage: _nextImage,
                onPrevImage: _previousImage,
                onTap: _onImageTap,
              ),
            ),
          ],
        ),
      ),
      1100: Scaffold(
        appBar: EditorAppBar(
          onProjectCreate: _createProject,
          onProjectOpen: _pickProject,
          onProjectSave: _saveProject,
          onUndo: _undo,
          onRedo: _redo,
          onSetting: () => context.go("/settings"),
          controller: _controller,
        ),
        body: Row(
          children: [
            Toolbar(
              toolSelectIndex: _toolSelectionIndex,
              onToolSelected: _selectTool,
            ),
            Expanded(
              flex: 8,
              child: EditorBody(
                onImageOpen: _pickImage,
                currentIndex: _currentIndex,
                annotations: _annotations,
                onNextImage: _nextImage,
                onPrevImage: _previousImage,
                onTap: _onImageTap,
              ),
            ),
            Card(
              shape: ContinuousRectangleBorder(),
              margin: EdgeInsets.zero,
              elevation: 5,
              child: SizedBox(
                width: 300,
                child: Column(
                  children: [
                    Expanded(child: Inspector()),
                    Expanded(
                      flex: 2,
                      child: Hierarchy(
                        annotations: _annotations,
                        selectIndex: _currentIndex,
                        onSelection: _changeImageAt,
                        onPickImage: _pickImage,
                        onPickFolder: _pickFolder,
                        onDelete: _deleteImage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    });
  }
}

class EditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EditorAppBar({
    super.key,
    required this.onProjectOpen,
    required this.onProjectSave,
    required this.onSetting,
    required this.controller,
    required this.onProjectCreate,
    required this.onUndo,
    required this.onRedo,
  });

  final VoidCallback onProjectCreate;
  final VoidCallback onProjectOpen;
  final VoidCallback onProjectSave;
  final VoidCallback onSetting;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: EditableTitleField(controller: controller),
      centerTitle: true,
      actions: [
        IconButton(onPressed: onSetting, icon: Icon(Icons.settings)),
      ],
      bottom: CommandBar(
        leftActions: [
          IconButton(
              onPressed: onProjectCreate,
              icon: Icon(FontAwesomeIcons.fileCirclePlus)),
          IconButton(
              onPressed: onProjectOpen,
              icon: Icon(FontAwesomeIcons.folderOpen)),
          IconButton(
              onPressed: onProjectSave,
              icon: Icon(FontAwesomeIcons.floppyDisk)),
        ],
        rightActions: [
          IconButton(
              onPressed: onUndo, icon: Icon(FontAwesomeIcons.arrowRotateLeft)),
          IconButton(
              onPressed: onRedo, icon: Icon(FontAwesomeIcons.arrowRotateRight)),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80);
}

class CommandBar extends StatelessWidget implements PreferredSizeWidget {
  const CommandBar({
    super.key,
    this.leftActions,
    this.centerActions,
    this.rightActions,
    this.leftMargin = 45,
    this.rightMargin = 45,
  });

  final List<Widget>? leftActions;
  final List<Widget>? centerActions;
  final List<Widget>? rightActions;
  final int leftFlex = 3;
  final int centerFlex = 4;
  final int rightFlex = 3;
  final double leftMargin;
  final double rightMargin;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(width: leftMargin),
        Flexible(
          flex: leftFlex,
          child: Row(
            children: [...?leftActions],
          ),
        ),
        Flexible(
          flex: centerFlex,
          child: Row(
            children: [...?centerActions],
          ),
        ),
        Flexible(
          flex: rightFlex,
          child: Row(
            children: [...?rightActions],
          ),
        ),
        SizedBox(width: rightMargin),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(30);
}

class Inspector extends StatelessWidget {
  const Inspector({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [],
    );
  }
}

class Hierarchy extends StatelessWidget {
  const Hierarchy({
    super.key,
    required this.annotations,
    required this.selectIndex,
    required this.onSelection,
    required this.onPickImage,
    required this.onPickFolder,
    required this.onDelete,
  });

  final VoidCallback onPickImage;
  final VoidCallback onPickFolder;
  final VoidCallback onDelete;

  final List<AnnotationData> annotations;
  final int selectIndex;

  final void Function(int selection) onSelection;

  List<Widget> generateLayerList(BuildContext context) {
    final indicatorColor = Theme.of(context).colorScheme.secondaryContainer;

    return List<Widget>.generate(
      annotations.length,
      (index) => ListTile(
        selected: index == selectIndex,
        selectedColor: Colors.blueAccent,
        selectedTileColor: indicatorColor,
        onTap: () => onSelection(index),
        // key: PageStorageKey(index),
        leading: Text("$index"),
        title: Text(basename(annotations[index].image.path)),
        minTileHeight: 30,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: SizedBox(
            height: 40,
            child: Row(
              children: [
                IconButton(
                  onPressed: onPickImage,
                  icon: Icon(FontAwesomeIcons.images),
                ),
                IconButton(
                  onPressed: onPickFolder,
                  icon: Icon(FontAwesomeIcons.folderPlus),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(FontAwesomeIcons.trash),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.black12,
            child: ListView(
              children: generateLayerList(context),
            ),
          ),
        ),
      ],
    );
  }
}

class Toolbar extends StatelessWidget {
  const Toolbar({
    super.key,
    required this.toolSelectIndex,
    required this.onToolSelected,
  });

  final int toolSelectIndex;
  final void Function(int index) onToolSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      indicatorShape: ContinuousRectangleBorder(),
      minWidth: 40,
      elevation: 5,
      destinations: [
        NavigationRailDestination(
          icon: Icon(FontAwesomeIcons.arrowPointer),
          label: Text("Bubble View"),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.rectangle_outlined),
          label: Text(""),
        ),
      ],
      onDestinationSelected: onToolSelected,
      selectedIndex: toolSelectIndex,
    );
  }
}

class EditorBody extends StatelessWidget {
  const EditorBody({
    super.key,
    required this.onImageOpen,
    required this.currentIndex,
    required this.annotations,
    required this.onNextImage,
    required this.onPrevImage,
    required this.onTap,
  });

  final List<AnnotationData> annotations;
  final int currentIndex;
  final VoidCallback onImageOpen;
  final VoidCallback onNextImage;
  final VoidCallback onPrevImage;
  final void Function(TapDownDetails details) onTap;

  Widget emptyLayout() {
    return GestureDetector(
      onTap: onImageOpen,
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: Text("画像がありません。画面をクリックするか、フォルダーボタンから画像を追加してください。"),
        ),
      ),
    );
  }

  Widget editLayout() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              BlurImage(image: annotations[currentIndex].image, onTap: onTap),
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
        Text("${currentIndex + 1} / ${annotations.length}"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      child: annotations.isEmpty ? emptyLayout() : editLayout(),
    );
  }
}
