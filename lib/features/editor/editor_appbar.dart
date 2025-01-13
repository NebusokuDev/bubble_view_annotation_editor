import 'package:bubble_view_annotation_editor/components/settings_button.dart';
import 'package:bubble_view_annotation_editor/features/editor/editor_dialog.dart';
import 'package:bubble_view_annotation_editor/features/editor/history_notifier.dart';
import 'package:bubble_view_annotation_editor/features/editor/project_metadata_dialog.dart';
import 'package:bubble_view_annotation_editor/features/editor/project_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EditorAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const EditorAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);
    return Material(
      elevation: 1,
      child: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: "プロジェクト名を編集する",
              child: IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => ProjectNameEditingDialog());
                  },
                  icon: Icon(Icons.edit)),
            ),
            Text(project?.metaData.projectName ?? "undefined"),
          ],
        ),
        centerTitle: true,
        leading: SettingsButton(),
        bottom: CommandBar(
          leftActions: [
            Tooltip(
              message: "プロジェクトを新規作成",
              child: IconButton(
                onPressed: () => createNewProject(context, ref),
                icon: Icon(FontAwesomeIcons.fileCirclePlus),
              ),
            ),
            Tooltip(
              message: "プロジェクトファイルを開く",
              child: IconButton(
                onPressed: ref.read(projectProvider.notifier).openProject,
                icon: Icon(FontAwesomeIcons.folderOpen),
              ),
            ),
            Tooltip(
              message: "プロジェクトを保存",
              child: IconButton(
                  onPressed: project == null
                      ? null
                      : () async =>
                          ref.read(projectProvider.notifier).saveProject(),
                  icon: Icon(FontAwesomeIcons.floppyDisk)),
            ),
          ],
          centerActions: [
            Tooltip(
              message: "メタデータの設定",
              child: IconButton(
                onPressed: project == null
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          builder: (context) => ProjectMetadataEditingDialog(),
                        );
                      },
                icon: Icon(Icons.dashboard),
              ),
            )
          ],
          rightActions: [
            IconButton(
              onPressed: ref.watch(historyProvider).canUndo
                  ? ref.read(historyProvider.notifier).undo
                  : null,
              icon: Icon(FontAwesomeIcons.arrowRotateLeft),
            ),
            IconButton(
                onPressed: ref.watch(historyProvider).canRedo
                    ? ref.read(historyProvider.notifier).redo
                    : null,
                icon: Icon(FontAwesomeIcons.arrowRotateRight)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: Scaffold.of(context).openEndDrawer,
            icon: Icon(Icons.menu),
          ),
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
    return Material(
      child: Row(
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
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(30);
}
