import 'package:bubble_view_annotation_editor/features/editor/editor_state.dart';
import 'package:bubble_view_annotation_editor/features/editor/project_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Inspector extends ConsumerWidget {
  const Inspector({super.key});

  Widget createKeyPointUI() {
    return Container();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);
    final index = ref.watch(editorStateProvider).currentImageIndex;

    if (project?.dataset.isEmpty ?? true) return Container();
    final annotation = project!.dataset.annotations[index];

    return SingleChildScrollView(
      // child: Column(
      //   children: [
      //     ExpansionTile(
      //       title: Text("ラベル"),
      //     ),
      //     if (annotation.clickPoints.isNotEmpty)
      //       ExpansionTile(
      //         title: Text("クリックポイント"),
      //         children: [
      //           ...annotation.clickPoints.map((e) {
      //             return ListTile(
      //               leading: Text(e.id.toString()),
      //               title: Text(
      //                   "[x: ${e.position.dx.toStringAsFixed(1)}, y: ${e.position.dy.toStringAsFixed(1)}]"),
      //             );
      //           })
      //         ],
      //       ),
      //   ],
      // ),
    );
  }
}
