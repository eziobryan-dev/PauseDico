import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/special_quiz_model.dart';

/// App bar icon of a pending special quiz, with a pulsing glow of its color:
/// blue quiz bubble for the monthly quiz, golden thinking head for the yearly quiz
class GlowingQuizButton extends StatefulWidget {
  final QuizKind kind;
  final VoidCallback onPressed;

  const GlowingQuizButton({
    super.key,
    required this.kind,
    required this.onPressed,
  });

  static IconData iconOf(QuizKind kind) => switch (kind) {
        QuizKind.yearly => Icons.psychology_alt_rounded,
        _ => Icons.quiz_rounded,
      };

  static Color colorOf(QuizKind kind) => switch (kind) {
        QuizKind.yearly => AppColors.warning,
        _ => AppColors.info,
      };

  @override
  State<GlowingQuizButton> createState() => _GlowingQuizButtonState();
}

class _GlowingQuizButtonState extends State<GlowingQuizButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = GlowingQuizButton.colorOf(widget.kind);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final glow = Curves.easeInOut.transform(_controller.value);
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.25 + 0.45 * glow),
                blurRadius: 8 + 10 * glow,
                spreadRadius: 1 + 3 * glow,
              ),
            ],
          ),
          child: child,
        );
      },
      child: IconButton(
        tooltip: widget.kind.title,
        onPressed: widget.onPressed,
        icon: Icon(GlowingQuizButton.iconOf(widget.kind), color: color),
      ),
    );
  }
}
