import 'package:flutter/material.dart';

/// Generic confirmation dialog used before destructive actions.
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final Color? confirmColor;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.confirmColor,
  });

  /// Show the dialog and return true if confirmed.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        confirmColor: confirmColor,
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor =
        confirmColor ?? theme.colorScheme.error;

    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: effectiveColor),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
