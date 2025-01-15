import 'package:bubble_view_annotation_editor/features/editor/project_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'editor_state.dart';

class ProjectMetadataEditingDialog extends ConsumerWidget {
  const ProjectMetadataEditingDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = Theme.of(context).textTheme;
    final nameController = TextEditingController(
      text: ref.watch(projectProvider)?.metaData.projectName,
    );

    return Dialog(
      child: SizedBox(
        width: 900,
        height: 600,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 32,
          ),
          child: Column(
            children: [
              Text(
                "メタデータを編集",
                style: style.headlineSmall,
              ),
              Spacer(),
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 20,
                    children: [
                      ListTile(
                        title: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text("プロジェクト名"),
                        ),
                        subtitle: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: () => ref
                                  .read(projectProvider.notifier)
                                  .changeProjectName(""),
                              icon: Icon(Icons.clear),
                            ),
                          ),
                        ),
                      ),
                      LabelTile(),
                      BubbleViewTile(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FilledButton(
                      onPressed: Navigator.of(context).pop,
                      child: Text("閉じる"),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
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
      title: Text("ラベル"),
      children: [
        ...?project?.metaData.projectLabels.asMap().entries.map(
              (e) => ListTile(
                leading: Text(e.value.id.toString()),
                title: Text(e.value.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () => ref
                            .read(projectProvider.notifier)
                            .removeProjectLabels(e.key),
                        icon: Icon(Icons.delete))
                  ],
                ),
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
    final editorState = ref.watch(editorStateProvider);

    return ExpansionTile(
      title: Text("Bubble View"),
      children: [
        SwitchListTile(
          title: Text("画像をぼかす"),
          value: editorState.enableBlur,
          onChanged: ref.read(editorStateProvider.notifier).switchBlur,
        ),
        ListTile(
          title: Text("ぼかし"),
          trailing: Text(
              (project?.bubbleViewConstraints.blurAmount.clamp(0, 200) ?? 30)
                  .toStringAsFixed(2)),
          subtitle: Slider(
            label: (project?.bubbleViewConstraints.blurAmount ?? 30)
                .clamp(0, 200)
                .toStringAsFixed(2),
            value: ref
                    .watch(projectProvider)
                    ?.bubbleViewConstraints
                    .blurAmount
                    .clamp(0, 200) ??
                5,
            onChanged: ref.read(projectProvider.notifier).changeBlurAmount,
            max: 200,
          ),
        ),
        ListTile(
          title: Text("バブルの半径"),
          trailing: Text(
              (project?.bubbleViewConstraints.bubbleRadius.clamp(30, 200) ?? 30)
                  .toStringAsFixed(2)),
          subtitle: Slider(
            label: (project?.bubbleViewConstraints.bubbleRadius ?? 30)
                .clamp(10, 200)
                .toStringAsFixed(2),
            value: ref
                    .watch(projectProvider)
                    ?.bubbleViewConstraints
                    .bubbleRadius
                    .clamp(1, 200) ??
                30,
            onChanged: ref.read(projectProvider.notifier).changeBubbleRadius,
            min: 10,
            max: 200,
          ),
        ),
        ListTile(
          title: Text("最大クリック回数"),
          trailing: Text(
              (project?.bubbleViewConstraints.clickLimit.round() ?? 30)
                  .toStringAsFixed(0)),
          subtitle: Slider(
            label: (project?.bubbleViewConstraints.clickLimit
                        .clamp(10, 200)
                        .round() ??
                    30)
                .toStringAsFixed(0),
            value: project?.bubbleViewConstraints.clickLimit
                    .clamp(10, 200)
                    .toDouble() ??
                30.0,
            onChanged: (value) => ref
                .read(projectProvider.notifier)
                .changeBubbleClickCountLimit(value.round()),
            min: 10,
            max: 200,
          ),
        ),
      ],
    );
  }
}
