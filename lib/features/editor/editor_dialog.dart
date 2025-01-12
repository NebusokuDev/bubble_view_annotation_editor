import 'package:bubble_view_annotation_editor/features/editor/project_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectOverwriteDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ProjectOverwriteDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(10 * 2.3529),
      ),
      title: const Text("新しいプロジェクトを作成しますか？"),
      content: const Text("現在のプロジェクトは破棄されます。この操作を続行してもよろしいですか？"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm();
          },
          child: const Text("続行"),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("キャンセル"),
        ),
      ],
    );
  }
}

class ProjectCreateDialog extends StatelessWidget {
  final ValueChanged<String?> onCreate;

  const ProjectCreateDialog({super.key, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme;
    final nameController = TextEditingController(text: "名称未設定のプロジェクト");
    return Dialog(
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(10 * 2.3529),
      ),
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
                "新しいプロジェクト",
                style: style.headlineSmall,
              ),
              Spacer(),
              Expanded(
                flex: 5,
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
                          hintText: "My New Project",
                          suffixIcon: IconButton(
                            onPressed: () => nameController.text = "",
                            icon: Icon(Icons.clear),
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text("ラベルを追加"),
                      ),
                      subtitle: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "monkey",
                                suffixIcon: IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.new_label),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ExpansionTile(
                              title: Text("ラベル"),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Spacer(),
              Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: const Text("キャンセル"),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop(nameController.text);
                      onCreate(nameController.text);
                    },
                    child: const Text("作成"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> createNewProject(BuildContext context, WidgetRef ref) async {
  final currentProject = ref.watch(projectProvider);
  if (currentProject != null) {
    final agreeToCreateNew = await showDialog<bool?>(
      context: context,
      builder: (context) => ProjectOverwriteDialog(
        onConfirm: () {},
      ),
    );

    debugPrint(agreeToCreateNew.toString());
    if (agreeToCreateNew == false || agreeToCreateNew == null) return;
  }

  // プロジェクト名入力ダイアログ
  final projectName = await showDialog<String>(
    context: context,
    builder: (context) => ProjectCreateDialog(onCreate: (_) {}),
  );

  // ユーザーがキャンセルした場合
  if (projectName == null || projectName.isEmpty) return;

  // プロジェクトの作成処理を実行
  ref.read(projectProvider.notifier).createProject(name: projectName);
}
