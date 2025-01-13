import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "設定画面",
      child: IconButton(
          onPressed: () => context.go("/settings"), icon: Icon(Icons.settings)),
    );
  }
}
