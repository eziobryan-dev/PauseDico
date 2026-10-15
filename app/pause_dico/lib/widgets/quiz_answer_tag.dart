import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Visual state of an answer tag once the user has answered
enum QuizAnswerState { idle, correct, wrong, dimmed }

/// Clickable word tag: green when it is the right answer, red when wrongly picked
class QuizAnswerTag extends StatelessWidget {
  final String label;
  final QuizAnswerState state;
  final VoidCallback? onTap;

  const QuizAnswerTag({
    super.key,
    required this.label,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final (Color background, Color foreground, IconData? icon) = switch (state) {
      QuizAnswerState.correct => (AppColors.success, Colors.white, Icons.check_circle),
      QuizAnswerState.wrong => (AppColors.danger, Colors.white, Icons.cancel),
      QuizAnswerState.dimmed => (
          colorScheme.surfaceContainerHighest,
          colorScheme.onSurface.withValues(alpha: 0.4),
          null,
        ),
      QuizAnswerState.idle => (
          colorScheme.primaryContainer,
          colorScheme.onPrimaryContainer,
          null,
        ),
    };
    final isHighlighted =
        state == QuizAnswerState.correct || state == QuizAnswerState.wrong;

    return AnimatedScale(
      scale: isHighlighted ? 1.08 : 1,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                if (isHighlighted)
                  BoxShadow(
                    color: background.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: foreground, size: 18),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
