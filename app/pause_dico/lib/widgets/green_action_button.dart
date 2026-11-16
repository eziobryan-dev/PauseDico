import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Full-width green call-to-action of the dark reveal overlay
class GreenActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const GreenActionButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
