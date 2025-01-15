import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
  const ProgressDialog({
    super.key,
    required this.current,
    required this.total,
    this.onCancel,
    this.details,
    this.title,
  });

  final String? title;
  final ValueNotifier<double> current;
  final ValueNotifier<double> total;
  final ValueNotifier<String>? details;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    if (current.value >= total.value) {
      Navigator.of(context).pop();
    }

    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          LinearProgressIndicator(
            value: (current.value / total.value),
            semanticsValue: "${current.value} / ${total.value}",
            semanticsLabel: details?.value,
          ),
          Text(
              "${current.value.toStringAsFixed(2)} / ${total.value.toStringAsFixed(2)}"),
        ],
      ),
      actions: [
        if (onCancel != null)
          FilledButton(
            onPressed: () {
              onCancel;
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          )
      ],
    );
  }
}

void showProgressDialog(
  BuildContext context,
  ValueNotifier<double> current,
  ValueNotifier<double> total, {
  VoidCallback? onCancel,
  ValueNotifier<String>? details,
}) => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => ProgressDialog(
      current: current,
      total: total,
      onCancel: onCancel,
      details: details,
    ),
  );
