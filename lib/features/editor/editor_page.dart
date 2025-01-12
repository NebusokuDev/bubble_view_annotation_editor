import 'package:bubble_view_annotation_editor/components/responsive_layout.dart';
import 'package:bubble_view_annotation_editor/features/editor/hierarchy.dart';
import 'package:bubble_view_annotation_editor/features/editor/inspector.dart';
import 'package:bubble_view_annotation_editor/features/editor/toolbar.dart';
import 'package:flutter/material.dart';

import 'editor_appbar.dart';
import 'editor_body.dart';

class EditorPage extends StatelessWidget {
  const EditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final body = EditorBody();
    final inspector = Inspector();
    final hierarchy = Hierarchy();
    final toolbar = Toolbar();
    final appBar = EditorAppBar();

    return ResponsiveLayout(
      layouts: {
        0: Scaffold(
          appBar: appBar,
          endDrawer: Drawer(
            shape: ContinuousRectangleBorder(),
            child: Column(
              children: [
                Expanded(child: inspector),
                Expanded(child: hierarchy),
              ],
            ),
          ),
          body: Row(children: [toolbar, Expanded(child: body)]),
        ),
        1100: Scaffold(
          appBar: appBar,
          body: Row(
            children: [
              toolbar,
              Expanded(
                flex: 8,
                child: body,
              ),
              Card(
                shape: ContinuousRectangleBorder(),
                margin: EdgeInsets.zero,
                elevation: 5,
                child: SizedBox(
                  width: 300,
                  child: Column(
                    children: [
                      Expanded(
                        child: inspector,
                      ),
                      Expanded(
                        child: hierarchy,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      },
    );
  }
}
