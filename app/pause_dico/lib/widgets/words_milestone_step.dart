import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'reveal_step_view.dart';

/// Reveal overlay step: a new "words unlocked" milestone (every 50 words)
class WordsMilestoneStep extends StatelessWidget {
  final int words;
  final VoidCallback onContinue;

  const WordsMilestoneStep({super.key, required this.words, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RevealStepView(
      title: 'Nouveau palier !',
      art: Container(
        width: 150,
        height: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.info.withValues(alpha: 0.2),
          border: Border.all(color: AppColors.info, width: 4),
        ),
        child: FittedBox(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              '$words',
              style: theme.textTheme.displayMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
      caption: '$words mots débloqués depuis ton inscription.',
      onContinue: onContinue,
    );
  }
}
