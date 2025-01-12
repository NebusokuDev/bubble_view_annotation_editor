import 'package:bubble_view_annotation_editor/core/settings.dart';
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

    if (project?.dataset.isEmpty ?? true) return Container();

    return SingleChildScrollView(
      child: Column(
        children: [
          LabelTile(),
          BubbleViewTile(),
        ],
      ),
    );
  }
}

class LabelTile extends ConsumerStatefulWidget {
  const LabelTile({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => LabelTileState();
}

class LabelTileState extends ConsumerState {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(projectProvider);

    return ExpansionTile(
      initiallyExpanded: ref.watch(settingsProvider).initialTileOpen,
      title: Text("ラベル"),
      children: [
        ...?project?.metaData.projectLabels.map(
          (label) => ListTile(
            leading: Text(label.id.toString()),
            title: Text(label.name),
          ),
        ),
        ListTile(
          title: TextField(
            controller: controller,
            onEditingComplete: () {
              final labelText = controller.text.trim();
              if (labelText.isNotEmpty) {
                ref
                    .read(projectProvider.notifier)
                    .addProjectLabels(controller.text);
                setState(() => controller.clear());
              }
            },
            decoration: InputDecoration(
              hintText: "ラベルを入力",
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  final labelText = controller.text.trim();
                  if (labelText.isNotEmpty) {
                    ref
                        .read(projectProvider.notifier)
                        .addProjectLabels(controller.text);
                    setState(() => controller.clear());
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BubbleViewTile extends ConsumerWidget {
  const BubbleViewTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);
    final settings = ref.watch(settingsProvider);
    final editorState = ref.watch(editorStateProvider);

    return ExpansionTile(
      initiallyExpanded: settings.initialTileOpen,
      title: Text("Bubble View"),
      children: [
        SwitchListTile(
          title: Text("画像をぼかす"),
          value: editorState.enableBlur,
          onChanged: ref.read(editorStateProvider.notifier).switchBlur,
        ),
        ListTile(
          title: Text("バブルの半径"),
          trailing: Text(
              (project?.bubbleViewConstraints.bubbleRadius.clamp(30, 200) ?? 30)
                  .toStringAsFixed(2)),
          subtitle: Slider(
            label: (project?.bubbleViewConstraints.bubbleRadius ?? 30)
                .clamp(30, 200)
                .toStringAsFixed(2),
            value: ref
                    .watch(projectProvider)
                    ?.bubbleViewConstraints
                    .bubbleRadius
                    .clamp(30, 200) ??
                30,
            onChanged: ref.read(projectProvider.notifier).changeBubbleRadius,
            min: 10,
            max: 200,
          ),
        ),
        ListTile(
          title: Text("最大クリック回数"),
          trailing: Text(
              (project?.bubbleViewConstraints.saliencyClickLimit.round() ?? 30)
                  .toStringAsFixed(0)),
          subtitle: Slider(
            label: (project?.bubbleViewConstraints.saliencyClickLimit
                        .clamp(30, 200)
                        .round() ??
                    30)
                .toStringAsFixed(0),
            value: project?.bubbleViewConstraints.saliencyClickLimit
                    .clamp(30, 200)
                    .toDouble() ??
                30.0,
            onChanged: (value) => ref
                .read(projectProvider.notifier)
                .changeBubbleClickCount(value.round()),
            min: 10,
            max: 200,
          ),
        ),
      ],
    );
  }
}
