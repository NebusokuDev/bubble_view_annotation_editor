import 'dart:io';

import 'package:bubble_view_annotation_editor/core/annotations.dart';
import 'package:bubble_view_annotation_editor/core/project_file_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectNotifier extends StateNotifier<Project?> {
  ProjectNotifier(super.state, this.ref);

  final Ref ref;

  bool get isProjectOpen => state != null;

  void createProject({String name = "undefined"}) {
    state = Project(metaData: Metadata(projectName: name));
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

    addAnnotations(dir
        .listSync()
        .where((item) => item is File && isImageFile(item.path))
        .map((item) => File(item.path))
        .toList());
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

    addAnnotations(results?.files.map((f) => File(f.path!)).toList() ?? []);
  }

  void addAnnotations(List<File>? newImages) {
    if (newImages == null) return;

    for (final image in newImages) {
      state?.dataset;
    }
  }

  void deleteImage(int index) {
    if (state == null) return;
    if (index >= 0 && index < state!.dataset.annotations.length) {
      state?.dataset.annotations.removeAt(index);
    }
  }

  void addImageLabels(Label label, int index) {
    state?.dataset.annotations[index].copyWith(imageLabels: [label]);
  }

  void addProjectLabels(String label) {
    if (state == null) return;

    final projectLabels = state!.metaData.projectLabels;
    projectLabels.sort((a, b) => a.id.compareTo(b.id));

    final newId = projectLabels.isEmpty ? 1 : projectLabels.last.id + 1;
    state = state?.copyWith(
        metaData: state?.metaData.copyWith(projectLabels: projectLabels));
  }

  void addSaliencyPoint(TapDownDetails details, int index) {
    final data = state?.dataset.annotations[index];

    if (data == null) return;

    if (data.clickPoints.length >
        (state?.bubbleViewConstraints.saliencyClickLimit ?? 30)) {
      return;
    }
  }

  void changeBubbleRadius(double value) {
    state?.bubbleViewConstraints.bubbleRadius = value;
  }

  void changeBubbleClickCount(int value) {
    state?.bubbleViewConstraints.saliencyClickLimit = value;
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
