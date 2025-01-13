import 'package:flutter/material.dart';

class TapShield extends StatelessWidget {
  final bool allowTap;
  final Widget child;

  const TapShield({
    super.key,
    required this.allowTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !allowTap,
      child: Container(
        color: allowTap ? Colors.transparent : Colors.black12,
        child: child,
      ),
    );
  }
}
