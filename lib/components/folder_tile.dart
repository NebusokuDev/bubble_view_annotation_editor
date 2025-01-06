import 'package:flutter/material.dart';

class FolderTile extends StatefulWidget {
  final Widget title;
  final List<Widget>? children;
  final VoidCallback? onTap;
  final bool? selected;
  final Color? selectedColor;
  final Color? selectedTileColor;

  const FolderTile({
    super.key,
    required this.title,
    this.children,
    required this.onTap,
    this.selected,
    this.selectedColor,
    this.selectedTileColor,
  });

  @override
  FolderTileState createState() => FolderTileState();
}

class FolderTileState extends State<FolderTile> {
  bool _isExpanded = false;

  void toggleExpand() => setState(() => _isExpanded = !_isExpanded);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          selected: widget.selected ?? false,
          onTap: widget.onTap,
          title: widget.title,
          trailing: widget.children?.isEmpty ?? true
              ? null
              : IconButton(
                  onPressed: toggleExpand,
                  icon:
                      Icon(_isExpanded ? Icons.expand_more : Icons.expand_less),
                ),
        ),
        if (_isExpanded) ...?widget.children,
      ],
    );
  }
}
