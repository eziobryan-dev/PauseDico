import 'package:flutter/material.dart';

import '../models/quiz_result_model.dart';
import 'quiz_rating_stars.dart';
import 'quiz_result_dialog.dart';

/// Card of a quiz already completed: no play button, its result instead,
/// tinted with the rating color (unlike the tertiary "play" FeatureCard)
class QuizDoneCard extends StatelessWidget {
  final String title;
  final QuizResultModel result;

  const QuizDoneCard({super.key, required this.title, required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rating = result.rating;
    final color = QuizResultDialog.colorOf(rating);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.18),
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          ],
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _DoneBadge(color: color),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(QuizResultDialog.iconOf(rating), size: 40, color: color),
              const SizedBox(width: 12),
              Text(
                '${result.score} / ${result.total}',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          QuizRatingStars(rating: rating, size: 28),
          const SizedBox(height: 8),
          Text(
            rating.title,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _DoneBadge extends StatelessWidget {
  final Color color;

  const _DoneBadge({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
          SizedBox(width: 6),
          Text(
            'Quiz terminé',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
