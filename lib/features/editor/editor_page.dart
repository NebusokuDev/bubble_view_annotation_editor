import 'dart:io';

import 'package:bubble_view_annotation_editor/components/folder_tile.dart';
import 'package:bubble_view_annotation_editor/components/responsive_layout.dart';
import 'package:bubble_view_annotation_editor/core/annotations.dart';
import 'package:bubble_view_annotation_editor/features/editor/blur_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart';
import 'package:undo/undo.dart';

class EditorState extends ChangeNotifier {
  final ChangeStack _history = ChangeStack();

  Project? project;

  int _currentImageIndex = 0;
  int _toolSelectionIndex = 0;
  double _blurAmount = 10;
  bool enableBlur = true;

  List<AnnotationData>? get annotations => project?.annotations;

  AnnotationData? get currentEditing {
    return project?.annotations.isEmpty ?? true
        ? null
        : project?.annotations[_currentImageIndex];
  }

  int get currentImage => _currentImageIndex;

  int get currentTool => _toolSelectionIndex;

  double get blurAmount => _blurAmount;

  set blurAmount(value) => _blurAmount = value;

  final TextEditingController titleController =
      TextEditingController(text: "undefined");

  void createProject({String name = "undefined"}) {
    project = Project();
    notifyListeners();
  }

  Future openProject() async {
    final selectFiles = await FilePicker.platform.pickFiles(
      allowedExtensions: ["anno", "json", "csv"],
      type: FileType.custom,
    );
    if (selectFiles == null) return;

    project = Project();
  }

  Future saveProject() async {
    final selectDirectory = await FilePicker.platform.saveFile(
      fileName: "${titleController.text}.anno",
      allowedExtensions: ["anno"],
      type: FileType.custom,
    );
    if (selectDirectory == null) return;
  }

  Future<void> pickFolder() async {
    final selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) return;

    final dir = Directory(selectedDirectory);

    addAnnotation(dir
        .listSync()
        .where((item) => item is File && isImageFile(item.path))
        .map((item) => File(item.path))
        .toList());
    notifyListeners();
  }

  bool isImageFile(String path) {
    final extensions = ['jpg', 'jpeg', 'png', 'bmp', 'gif'];
    final ext = path.split('.').last.toLowerCase();
    return extensions.contains(ext);
  }

  Future<void> pickImage() async {
    final results = await FilePicker.platform.pickFiles(
      dialogTitle: "select images",
      type: FileType.image,
      allowMultiple: true,
    );

    addAnnotation(results?.files.map((f) => File(f.path!)).toList() ?? []);
    notifyListeners();
  }

  void addAnnotation(List<File>? newImages) {
    if (newImages == null) return;

    project?.annotations
        .addAll(newImages.map((img) => AnnotationData(image: img)));

    notifyListeners();
  }

  void deleteImage() {
    if (project == null) return;
    if (_currentImageIndex >= 0 &&
        _currentImageIndex < project!.annotations.length) {
      project?.annotations.removeAt(_currentImageIndex);

      if (_currentImageIndex >= project!.annotations.length &&
          project!.annotations.isNotEmpty) {
        _currentImageIndex = project!.annotations.length - 1;
      } else if (project!.annotations.isEmpty) {
        _currentImageIndex = 0;
      }

      notifyListeners();
    }
  }

  void changeImageAt(int index) {
    _currentImageIndex = index;
    notifyListeners();
  }

  void nextImage() {
    if (project == null) return;
    final nextIndex = (_currentImageIndex + 1 + project!.annotations.length) %
        project!.annotations.length;

    changeImageAt(nextIndex);
    notifyListeners();
  }

  void previousImage() {
    if (project == null) return;
    final nextIndex = (_currentImageIndex - 1 + project!.annotations.length) %
        project!.annotations.length;
    changeImageAt(nextIndex);
    notifyListeners();
  }

  void addSaliencyPoint(TapDownDetails details) {
    project?.annotations[_currentImageIndex].bubbleViewClickPoints
        .add(details.localPosition);
    if (kDebugMode) {
      print(details.localPosition);
      print(project?.annotations[currentImage].bubbleViewClickPoints.length);
    }
    notifyListeners();
  }

  void selectTool(int index) {
    _toolSelectionIndex = index;
    notifyListeners();
  }

  void redo() {
    if (_history.canRedo) {
      _history.redo();
    }
    notifyListeners();
  }

  void undo() {
    if (_history.canUndo) {
      _history.undo();
    }
    notifyListeners();
  }
}

enum Task {
  bubbleView,
  keyPoints,
  detection,
  segmentation,
  classifier,
}

final editorStateProvider = ChangeNotifierProvider((ref) => EditorState());

class EditorPage extends ConsumerStatefulWidget {
  const EditorPage({super.key});

  @override
  ConsumerState<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends ConsumerState<EditorPage> {
  final List<ToolBarDestination> _tools = [
    ToolBarDestination(FontAwesomeIcons.arrowPointer, "Bubble View"),
    ToolBarDestination(FontAwesomeIcons.square, "矩形選択"),
    ToolBarDestination(FontAwesomeIcons.circle, "円形選択"),
    ToolBarDestination(FontAwesomeIcons.drawPolygon, "多角形選択"),
    ToolBarDestination(FontAwesomeIcons.circleDot, "キーポイント"),
    ToolBarDestination(FontAwesomeIcons.eraser, "削除"),
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(layouts: {
      0: Scaffold(
        appBar: EditorAppBar(
          onProjectCreate: ref.read(editorStateProvider).createProject,
          onProjectOpen: ref.read(editorStateProvider).openProject,
          onProjectSave: ref.read(editorStateProvider).saveProject,
          onUndo: ref.read(editorStateProvider).undo,
          onRedo: ref.read(editorStateProvider).redo,
          onSetting: () => context.go("/settings"),
          controller: ref.watch(editorStateProvider).titleController,
          projectName: ref.watch(editorStateProvider).project?.name ?? "",
        ),
        drawer: Drawer(
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Inspector(
                  annotationData: ref.watch(editorStateProvider).currentEditing,
                ),
              ),
              Expanded(
                flex: 1,
                child: Hierarchy(
                  annotations: ref.watch(editorStateProvider).annotations,
                  selectIndex: ref.watch(editorStateProvider).currentImage,
                  onSelection: ref.read(editorStateProvider).selectTool,
                  onPickImage: ref.read(editorStateProvider).pickImage,
                  onPickFolder: ref.read(editorStateProvider).pickFolder,
                  onDelete: ref.read(editorStateProvider).pickFolder,
                ),
              ),
            ],
          ),
        ),
        body: Row(
          children: [
            Toolbar(
              toolSelectIndex: ref.watch(editorStateProvider).currentTool,
              onToolSelected: ref.read(editorStateProvider).selectTool,
              tools: _tools,
            ),
            Expanded(
              flex: 8,
              child: EditorBody(
                onPickImage: ref.read(editorStateProvider).pickImage,
                currentIndex: ref.watch(editorStateProvider).currentImage,
                annotations: ref.watch(editorStateProvider).annotations,
                onNextImage: ref.read(editorStateProvider).nextImage,
                onPrevImage: ref.read(editorStateProvider).previousImage,
                onTap: ref.read(editorStateProvider).addSaliencyPoint,
              ),
            ),
          ],
        ),
      ),
      1100: Scaffold(
        appBar: EditorAppBar(
          onProjectCreate: ref.read(editorStateProvider).createProject,
          onProjectOpen: ref.read(editorStateProvider).openProject,
          onProjectSave: ref.read(editorStateProvider).saveProject,
          onUndo: ref.read(editorStateProvider).undo,
          onRedo: ref.read(editorStateProvider).redo,
          onSetting: () => context.go("/settings"),
          controller: ref.watch(editorStateProvider).titleController,
          projectName: ref.watch(editorStateProvider).project?.name ?? "",
        ),
        body: Row(
          children: [
            Toolbar(
              toolSelectIndex: ref.watch(editorStateProvider).currentTool,
              onToolSelected: ref.read(editorStateProvider).selectTool,
              tools: _tools,
            ),
            Expanded(
              flex: 8,
              child: EditorBody(
                onPickImage: ref.read(editorStateProvider).pickImage,
                currentIndex: ref.watch(editorStateProvider).currentImage,
                annotations: ref.watch(editorStateProvider).annotations,
                onNextImage: ref.read(editorStateProvider).nextImage,
                onPrevImage: ref.read(editorStateProvider).previousImage,
                onTap: ref.read(editorStateProvider).addSaliencyPoint,
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
                    Expanded(
                      child: Inspector(
                        annotationData:
                            ref.watch(editorStateProvider).currentEditing,
                      ),
                    ),
                    Expanded(
                      child: Hierarchy(
                        annotations: ref.watch(editorStateProvider).annotations,
                        selectIndex:
                            ref.watch(editorStateProvider).currentImage,
                        onSelection:
                            ref.read(editorStateProvider).changeImageAt,
                        onPickImage: ref.read(editorStateProvider).pickImage,
                        onPickFolder: ref.read(editorStateProvider).pickFolder,
                        onDelete: ref.read(editorStateProvider).deleteImage,
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
    required this.projectName,
  });

  final VoidCallback onProjectCreate;
  final VoidCallback onProjectOpen;
  final VoidCallback onProjectSave;
  final VoidCallback onSetting;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  final TextEditingController controller;
  final String projectName;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(projectName),
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
        centerActions: [
          ToggleButtons(
            borderColor: Colors.transparent,
            isSelected: [false, false, false],
            onPressed: (index) {},
            children: [
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(FontAwesomeIcons.font),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(FontAwesomeIcons.eye),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Icon(FontAwesomeIcons.circleDot),
              ),
            ],
          )
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
  CommandBar({
    super.key,
    this.leftActions,
    this.centerActions,
    this.rightActions,
    this.leftMargin = 45,
    this.rightMargin = 45,
    leftAlignment,
    centerAlignment,
    rightAlignment,
  }) {
    this.leftAlignment = leftAlignment ?? MainAxisAlignment.start;
    this.centerAlignment = centerAlignment ?? MainAxisAlignment.start;
    this.rightAlignment = rightAlignment ?? MainAxisAlignment.start;
  }

  final List<Widget>? leftActions;
  final List<Widget>? centerActions;
  final List<Widget>? rightActions;
  final int leftFlex = 3;
  final int centerFlex = 4;
  final int rightFlex = 3;
  final double leftMargin;
  final double rightMargin;
  late final MainAxisAlignment leftAlignment;
  late final MainAxisAlignment centerAlignment;
  late final MainAxisAlignment rightAlignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(width: leftMargin),
        Flexible(
          flex: leftFlex,
          child: Row(
            mainAxisAlignment: leftAlignment,
            children: leftActions ?? [],
          ),
        ),
        Flexible(
          flex: centerFlex,
          child: Row(
            mainAxisAlignment: centerAlignment,
            children: centerActions ?? [],
          ),
        ),
        Flexible(
          flex: rightFlex,
          child: Row(
            mainAxisAlignment: rightAlignment,
            children: rightActions ?? [],
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
  const Inspector({
    super.key,
    this.annotationData,
  });

  final AnnotationData? annotationData;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme;

    return FolderTile(
      title: Text(
        "BubbleView",
        style: style.labelLarge,
      ),
      onTap: () {},
      selected: null,
      selectedColor: null,
      children: [
        ListTile(
          title: Text("半径", style: style.labelMedium),
        )
      ],
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

  final List<AnnotationData>? annotations;
  final int selectIndex;

  final void Function(int selection) onSelection;

  List<Widget> generateLayerList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme;
    if (annotations == null) return [];
    return List<Widget>.generate(annotations!.length, (index) {
      final annotationData = annotations![index];
      final selected = index == selectIndex;
      return AnnotationTile(
        annotationData: annotationData,
        selected: selected,
        onSelection: () => onSelection(index),
      );
    });
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

class AnnotationTile extends StatelessWidget {
  const AnnotationTile({
    super.key,
    required this.annotationData,
    required this.selected,
    required this.onSelection,
  });

  final AnnotationData annotationData;
  final bool selected;
  final VoidCallback onSelection;

  List<Widget> buildAnnotationList() {
    final saliencyPoint = annotationData.bubbleViewClickPoints
        .map((e) => ListTile(
              title: Text("[${e.dx}, ${e.dy}]"),
            ))
        .toList();
    return [
      if (saliencyPoint.isNotEmpty)
        ExpansionTile(
          title: Text("Bubble View"),
          children: saliencyPoint,
        )
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme;

    return FolderTile(
      selected: selected,
      selectedColor: colorScheme.primary,
      selectedTileColor: colorScheme.primaryContainer,
      onTap: onSelection,
      // key: PageStorageKey(index),
      title: Text(
        basename(annotationData.image.path),
        style: style.labelMedium?.copyWith(
          color: selected ? colorScheme.primary : null,
        ),
      ),
      children: [],
    );
  }
}

class Toolbar extends StatelessWidget {
  const Toolbar({
    super.key,
    required this.toolSelectIndex,
    required this.onToolSelected,
    required this.tools,
  });

  final int toolSelectIndex;
  final void Function(int index) onToolSelected;
  final List<ToolBarDestination> tools;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      indicatorShape: ContinuousRectangleBorder(),
      minWidth: 40,
      elevation: 5,
      destinations: tools,
      onDestinationSelected: onToolSelected,
      selectedIndex: toolSelectIndex,
    );
  }
}

class ToolBarDestination extends NavigationRailDestination {
  ToolBarDestination(
    IconData icon,
    String message,
  ) : super(
          icon: Tooltip(
            message: message,
            child: Icon(icon),
          ),
          label: Text(message),
        );
}

class EditorBody extends StatelessWidget {
  const EditorBody({
    super.key,
    required this.onPickImage,
    required this.currentIndex,
    required this.annotations,
    required this.onNextImage,
    required this.onPrevImage,
    required this.onTap,
  });

  final List<AnnotationData>? annotations;
  final int currentIndex;
  final VoidCallback onPickImage;
  final VoidCallback onNextImage;
  final VoidCallback onPrevImage;
  final void Function(TapDownDetails details) onTap;

  Widget emptyLayout() {
    return GestureDetector(
      onTap: onPickImage,
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                child: IconButton.outlined(
                  onPressed: onNextImage,
                  icon: Icon(Icons.arrow_left),
                ),
              ),
              Expanded(
                flex: 12,
                child: BlurImage(
                  image: annotations![currentIndex].image,
                  onTap: onTap,
                  enableBlur: false,
                  blurAmount: 5.0,
                ),
              ),
              Flexible(
                child: IconButton.outlined(
                  onPressed: onNextImage,
                  icon: Icon(Icons.arrow_right),
                ),
              ),
            ],
          ),
        ),
        Text("${currentIndex + 1} / ${annotations!.length}"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = annotations?.isEmpty ?? true;

    return Container(
      color: Colors.black12,
      child: isEmpty ? emptyLayout() : editLayout(),
    );
  }
}
