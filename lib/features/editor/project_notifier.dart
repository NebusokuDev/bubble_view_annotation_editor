import 'dart:io';

import 'package:bubble_view_annotation_editor/core/annotations.dart';
import 'package:bubble_view_annotation_editor/core/project_file_handler.dart';
import 'package:bubble_view_annotation_editor/features/editor/editor_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectNotifier extends StateNotifier<Project?> {
  ProjectNotifier(super.state, this.ref);

  File? _file;

  final Ref ref;

  bool get isProjectOpen => state != null;

  void createProject(Metadata result) {
    state = Project(
      metaData: result,
    );
  }

  Future openProject() async {
    final selectFiles = await FilePicker.platform.pickFiles(
      allowedExtensions: ["anno", "sqlite"],
      type: FileType.custom,
    );

    if (selectFiles == null) return;

    _file = File(selectFiles.files.single.path!);
    state = await SQLiteProjectFileHandler().open(_file!.path);
  }

  Future<void> saveProject() async {
    if (state == null) return;

    // プロジェクト名を定義
    final fileName = "${state?.metaData.projectName ?? "undefined"}.anno";

    // 保存先のディレクトリを選択
    final savePath = await FilePicker.platform.saveFile(
      fileName: fileName,
      allowedExtensions: ["anno", "sqlite"],
      type: FileType.custom,
    );

    // 保存先が選択されなかった場合
    if (savePath == null) return;

    SQLiteProjectFileHandler().save(state!, savePath);

    try {
      // 保存するデータを取得
      final data = await _file?.readAsBytes();

      // 選択したパスにデータを書き込む
      final file = File(savePath);
      await file.writeAsBytes(data ?? []);

      debugPrint("ファイルが保存されました: $savePath");
    } catch (e) {
      debugPrint("ファイル保存中にエラーが発生しました: $e");
    }
  }

  Future<void> pickFolder() async {
    final selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) return;

    final dir = Directory(selectedDirectory);

    final images = dir
        .listSync()
        .where((item) => item is File && isImageFile(item.path))
        .map((item) => File(item.path))
        .toList();

    addAnnotations(images);
  }

  Future<void> pickImage() async {
    final results = await FilePicker.platform.pickFiles(
      dialogTitle: "select images",
      type: FileType.image,
      allowMultiple: true,
    );

    addAnnotations(results?.files.map((f) => File(f.path!)).toList() ?? []);
  }

  void addAnnotations(List<File>? newImages) {
    final annotations = state?.annotations;
    if (newImages == null) return;
    if (annotations == null) return;

    state = state?.copyWith(annotations: [
      ...annotations,
      ...newImages.map((image) {
        final id = annotations.isEmpty ? 1 : annotations.last.id;
        return Annotation(id: id, image: image);
      })
    ]);
  }

  void deleteImage(int index) {
    if (state == null) return;
    final annotations = state?.annotations;
    if (annotations == null || annotations.isEmpty) return;
    if (index >= 0 && index < state!.annotations.length) {
      annotations.removeAt(index);
    }

    state = state?.copyWith(annotations: [...annotations]);
  }

  void addImageLabels(Label label, int index) {
    final annotations = state?.annotations;

    if (annotations == null) return;

    final labels = annotations[index].imageLabels;

    if (labels.contains(label)) return;

    annotations[index].imageLabels = [...labels, label];

    state = state?.copyWith(annotations: annotations);
    ref.read(editorStateProvider.notifier).changeImageAt(index);
  }

  void addProjectLabels(String label) {
    if (state == null) return;

    final metadata = state!.metaData;

    final newId =
        metadata.projectLabels.isEmpty ? 1 : metadata.projectLabels.last.id + 1;

    state = state?.copyWith(
      metaData: metadata.copyWith(projectLabels: [
        ...metadata.projectLabels,
        Label(id: newId, name: label)
      ]),
    );
  }

  void removeProjectLabels(int index) {
    if (state == null) return;

    final metaData = state!.metaData;
    final projectLabels = metaData.projectLabels;
    projectLabels.removeAt(index);
    state = state?.copyWith(
      metaData: metaData.copyWith(
        projectLabels: [...projectLabels],
      ),
    );
  }

  void addClickPoint(TapDownDetails details, int index) {
    final annotations = state?.annotations;
    final constraints = state?.bubbleViewConstraints;

    if (annotations == null) return;
    final clickpoints = annotations[index].clickPoints;
    if (clickpoints.length > (constraints?.clickLimit ?? 0)) {
      ref.read(editorStateProvider.notifier).nextImage();
      return;
    }
    if (clickpoints.isNotEmpty) {
      clickpoints.sort();
    }
    final newId = clickpoints.isEmpty ? 1 : clickpoints.last.id + 1;

    final clickPoints = annotations[index].clickPoints;
    annotations[index].clickPoints = [
      ...clickPoints,
      ClickPoint(
          id: newId,
          position: details.localPosition,
          radius: constraints!.bubbleRadius)
    ];

    state = state?.copyWith(annotations: [...annotations]);

    ref.read(editorStateProvider.notifier).changeImageAt(index);
  }

  void changeBubbleRadius(double value) {
    final constraints = state?.bubbleViewConstraints;
    if (constraints == null) return;
    state = state?.copyWith(
      bubbleViewConstraints: constraints.copyWith(bubbleRadius: value),
    );
  }

  void changeBubbleClickCountLimit(int value) {
    final constraints = state?.bubbleViewConstraints;
    if (constraints == null) return;
    state = state?.copyWith(
      bubbleViewConstraints: constraints.copyWith(clickLimit: value),
    );
  }

  void changeBlurAmount(double value) {
    final constraints = state?.bubbleViewConstraints;
    if (constraints == null) return;
    state = state?.copyWith(
      bubbleViewConstraints: constraints.copyWith(blurAmount: value),
    );
  }

  void changeProjectName(String projectName) {
    final metadata = state?.metaData;
    if (metadata == null) return;

    state = state?.copyWith(
      metaData: metadata.copyWith(projectName: projectName),
    );
  }
}

bool isImageFile(String path) {
  final extensions = ['jpg', 'jpeg', 'png', 'bmp', 'gif'];
  final ext = path.split('.').last.toLowerCase();
  return extensions.contains(ext);
}

final projectProvider = StateNotifierProvider<ProjectNotifier, Project?>(
  (ref) => ProjectNotifier(null, ref),
);
