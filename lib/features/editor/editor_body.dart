import 'package:bubble_view_annotation_editor/features/editor/bubble_view.dart';
import 'package:bubble_view_annotation_editor/features/editor/editor_dialog.dart';
import 'package:bubble_view_annotation_editor/features/editor/editor_state.dart';
import 'package:bubble_view_annotation_editor/features/editor/project_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditorBody extends ConsumerWidget {
  const EditorBody({super.key});

  Widget imageEmpty(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.black12,
      child: GestureDetector(
        onTap: ref.read(projectProvider.notifier).pickImage,
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: Text("画像がありません。画面をクリックするか、フォルダーボタンから画像を追加してください。"),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);

    if (project == null) {
      return ProjectNotOpenCanvas();
    }

    if (project.dataset.isEmpty) {
      return imageEmpty(context, ref);
    }

    return BubbleViewCanvas();
  }
}

class ProjectNotOpenCanvas extends ConsumerWidget {
  const ProjectNotOpenCanvas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.black12,
      child: Center(
        child: Column(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("プロジェクトが開かれていません。"),
            TextButton(
              onPressed: ref.read(projectProvider.notifier).openProject,
              child: Text("プロジェクトを開く"),
            ),
            Text("または"),
            TextButton(
                onPressed: () async => await createNewProject(context, ref),
                child: Text("プロジェクトを作成")),
          ],
        ),
      ),
    );
  }
}

class BubbleViewCanvas extends ConsumerWidget {
  const BubbleViewCanvas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataset = ref.watch(projectProvider)!.dataset;
    final constraints = ref.watch(projectProvider)!.bubbleViewConstraints;
    final currentIndex =
        ref.watch(editorStateProvider.notifier).currentImageIndex;
    final editorState = ref.watch(editorStateProvider);

    return Container(
      color: Colors.black12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  child: IconButton.outlined(
                    onPressed:
                        ref.read(editorStateProvider.notifier).previousImage,
                    icon: Icon(Icons.arrow_left),
                  ),
                ),
                Expanded(
                  flex: 12,
                  child: BubbleView(
                    image: dataset.annotations[currentIndex].image,
                    onTapDown: (details) =>
                        ref.read(projectProvider.notifier).addSaliencyPoint(
                              details,
                              currentIndex,
                            ),
                    clipPos:
                        dataset.annotations[currentIndex].clickPoints.isNotEmpty
                            ? dataset.annotations[currentIndex].clickPoints.last
                                .position
                            : null,
                    enableBlur: editorState.enableBlur,
                    bubbleRadius: constraints.bubbleRadius,
                    blurAmount: 5.0,
                  ),
                ),
                Flexible(
                  child: IconButton.outlined(
                    onPressed: ref.read(editorStateProvider.notifier).nextImage,
                    icon: Icon(Icons.arrow_right),
                  ),
                ),
              ],
            ),
          ),
          Text("${currentIndex + 1} / ${dataset.annotations.length}"),
        ],
      ),
    );
  }
}
