import 'dart:collection';

import 'package:flutter/cupertino.dart';

class ResponsiveLayout extends StatelessWidget {
  final Map<int, Widget> layouts;

  const ResponsiveLayout({super.key, required this.layouts});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SplayTreeMap<int, Widget>.from(layouts, (a, b) => b.compareTo(a))
            .entries
            .firstWhere(
              (layout) => constraints.maxWidth >= layout.key,
              orElse: () => layouts.isEmpty
                  ? const MapEntry(0, SizedBox.shrink())
                  : layouts.entries.first,
            )
            .value;
      },
    );
  }
}
