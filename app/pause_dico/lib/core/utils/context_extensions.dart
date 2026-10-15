import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  /// Shows a simple text SnackBar
  void showSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 4),
      ),
    );
  }
}
