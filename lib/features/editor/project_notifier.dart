import 'dart:io';

import 'package:bubble_view_annotation_editor/core/annotations.dart';
import 'package:bubble_view_annotation_editor/core/project_file_handler.dart';
import 'package:bubble_view_annotation_editor/features/editor/history_notifier.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:undo/undo.dart';

class ProjectNotifier extends StateNotifier<Project?> {
  ProjectNotifier(super.state, this.ref);

  final Ref ref;

  bool get isProjectOpen => state != null;

  void createProject({String name = "undefined"}) {
    state = Project(metaData: Metadata(projectName: name));
    ref.read(historyProvider).clear();
  }

  Future openProject() async {
    final selectFiles = await FilePicker.platform.pickFiles(
      allowedExtensions: ["anno", "json", "csv"],
      type: FileType.custom,
    );

    if (selectFiles == null) return;

    final filePath = selectFiles.files.single.path!;
    state = await SQLiteProjectFileHandler().open(filePath);
  }

  Future saveProject() async {
    if (state == null) return;
    final selectDirectory = await FilePicker.platform.saveFile(
      fileName: "${state?.metaData.projectName ?? "undefined"}.anno",
      allowedExtensions: ["anno"],
      type: FileType.custom,
    );
    if (selectDirectory == null) return;
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
    final dataset = state?.dataset;
    if (newImages == null) return;
    if (dataset == null) return;
    for (final image in newImages) {
      final id = dataset.annotations.isEmpty ? 1 : dataset.annotations.last.id;
      final annotation = Annotation(id: id, image: image);
      state?.dataset.annotations = [...dataset.annotations, annotation];
    }

    ref.read(historyProvider.notifier).addChange(
          Change(
            state?.deepCopy(),
            () => state = state?.copyWith(dataset: dataset),
            (oldValue) => state = oldValue?.deepCopy(),
          ),
        );
  }

  void deleteImage(int index) {
    if (state == null) return;
    final dataset = state?.dataset;
    if (dataset?.annotations == null || dataset!.annotations.isEmpty) return;
    if (index >= 0 && index < state!.dataset.annotations.length) {
      dataset.annotations.removeAt(index);
    }
    state = state?.copyWith(dataset: dataset);
  }

  void addImageLabels(Label label, int index) {
    state?.dataset.annotations[index].copyWith(imageLabels: [label]);
  }

  void addProjectLabels(String label) {
    if (state == null) return;

    final metadata = state!.metaData;

    final newId =
        metadata.projectLabels.isEmpty ? 1 : metadata.projectLabels.last.id + 1;

    metadata.projectLabels = [
      ...metadata.projectLabels,
      Label(id: newId, name: label)
    ];
    state = state?.copyWith(metaData: metadata);
  }

  void removeProjectLabels(int index) {
    if (state == null) return;

    final metaData = state!.metaData;
    final projectLabels = metaData.projectLabels;
    projectLabels.removeAt(index);
    metaData.projectLabels = [...projectLabels];
    state = state?.copyWith(metaData: metaData);
  }

  void addClickPoint(TapDownDetails details, int index) {
    final dataset = state?.dataset;
    final constraints = state?.bubbleViewConstraints;

    if (dataset == null) return;
    final annotations = dataset.annotations;
    final newId = annotations.isEmpty ? 1 : annotations.last.id + 1;

    final clickPoints = annotations[index].clickPoints;
    annotations[index].clickPoints = [
      ...clickPoints,
      ClickPoint(
          id: newId,
          position: details.localPosition,
          radius: constraints!.bubbleRadius)
    ];
    dataset.annotations = [...annotations];
    state = state?.copyWith(dataset: dataset);
  }

  void changeBubbleRadius(double value) {
    final constraints = state?.bubbleViewConstraints;
    if (constraints == null) return;
    constraints.bubbleRadius = value;
    state = state?.copyWith(bubbleViewConstraints: constraints);
  }

  void changeBubbleClickCount(int value) {
    final constraints = state?.bubbleViewConstraints;
    if (constraints == null) return;
    constraints.saliencyClickLimit = value;
    state = state?.copyWith(bubbleViewConstraints: constraints);
  }

  void changeBlurAmount(double value) {
    final constraints = state?.bubbleViewConstraints;
    if (constraints == null) return;
    constraints.blurAmount = value;
    state = state?.copyWith(bubbleViewConstraints: constraints);
  }

  void changeProjectName(String text) {
    final metadata = state?.metaData;
    if (metadata == null) return;

    metadata.projectName = text;
    state = state?.copyWith(metaData: metadata);
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
