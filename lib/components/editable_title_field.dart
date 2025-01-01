import 'package:flutter/material.dart';

class EditableTitleField extends StatelessWidget {
  const EditableTitleField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 50),
      child: IntrinsicWidth(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.edit),
            border: InputBorder.none,
            focusedBorder: UnderlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
