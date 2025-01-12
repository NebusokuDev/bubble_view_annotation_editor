import 'package:bubble_view_annotation_editor/features/editor/editor_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final List<ToolBarDestination> tools = [
  ToolBarDestination(FontAwesomeIcons.magnifyingGlass, "Bubble View"),
  // ToolBarDestination(FontAwesomeIcons.square, "矩形選択"),
  // ToolBarDestination(FontAwesomeIcons.circle, "円形選択"),
  // ToolBarDestination(FontAwesomeIcons.drawPolygon, "多角形選択"),
  // ToolBarDestination(FontAwesomeIcons.circleDot, "キーポイント"),
  // ToolBarDestination(FontAwesomeIcons.eraser, "削除"),
];

class Toolbar extends ConsumerWidget {
  const Toolbar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NavigationRail(
      indicatorShape: ContinuousRectangleBorder(),
      minWidth: 40,
      elevation: 5,
      destinations: tools,
      onDestinationSelected: ref.read(editorStateProvider.notifier).selectTool,
      selectedIndex: ref.watch(editorStateProvider).currentToolIndex,
    );
  }
}

class ToolBarDestination extends NavigationRailDestination {
  ToolBarDestination(
    IconData icon,
    String message,
  ) : super(
          icon: Tooltip(message: message, child: Icon(icon)),
          label: Text(message),
        );
}
