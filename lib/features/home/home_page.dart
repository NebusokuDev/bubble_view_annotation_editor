import 'package:bubble_view_annotation_editor/core/resent_file_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  List<Widget> buildListContents(List<String> pathList) {
    return pathList.map((path) {
      return ListTile(leading: CircleAvatar(),title: Text(path),);
    }).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentFiles = ref.read(recentFileHistoryProvider).findAll();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 300),
          child: ListView(
            children: buildListContents(List.generate(10, (index) => index.toString())),
          ),
        ),
      ),
    );
  }
}
