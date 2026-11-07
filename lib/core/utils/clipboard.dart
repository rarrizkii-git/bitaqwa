import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Copies [text] and confirms the action with a snack bar.
Future<void> copyWithFeedback(
  BuildContext context,
  String text, {
  String message = 'Teks disalin ke clipboard.',
}) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
