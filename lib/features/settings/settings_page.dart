import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.go("/"),
        ),
        actions: [
          CircleAvatar(
            child: GestureDetector(
              onTap: () {
                context.go("/auth");
              },
            ),
          ),
          SizedBox(
            width: 10,
          ),
        ],
        title: Text('SETTINGS'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 128),
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("テーマモードの切替"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
