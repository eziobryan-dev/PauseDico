import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/quiz_result_model.dart';
import '../models/reward_summary_model.dart';
import 'pop_in.dart';
import 'reward_summary_view.dart';

/// End-of-quiz popup: rating title, colored score and stars.
/// Returns true when the user wants to play again.
class QuizResultDialog extends StatelessWidget {
  final QuizResultModel result;

  /// Rewards granted by the server; empty when this quiz was already completed
  /// (or is a past week's quiz: [noRewardMessage] explains why)
  final RewardSummaryModel? rewards;
  final String noRewardMessage;

  const QuizResultDialog({
    super.key,
    required this.result,
    this.rewards,
    this.noRewardMessage = 'Récompenses déjà obtenues pour ce quiz',
  });

  static Future<bool?> show(
    BuildContext context,
    QuizResultModel result, {
    RewardSummaryModel? rewards,
    String? noRewardMessage,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => noRewardMessage == null
          ? QuizResultDialog(result: result, rewards: rewards)
          : QuizResultDialog(
              result: result,
              rewards: rewards,
              noRewardMessage: noRewardMessage,
            ),
    );
  }

  static Color colorOf(QuizRating rating) => switch (rating) {
        QuizRating.perfect => AppColors.info,
        QuizRating.good => AppColors.success,
        QuizRating.average => AppColors.warning,
        QuizRating.zero => AppColors.danger,
      };

  static IconData iconOf(QuizRating rating) => switch (rating) {
        QuizRating.perfect => Icons.emoji_events_rounded,
        QuizRating.good => Icons.thumb_up_alt_rounded,
        QuizRating.average => Icons.sentiment_neutral_rounded,
        QuizRating.zero => Icons.sentiment_very_dissatisfied_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rating = result.rating;
    final color = colorOf(rating);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
        child: PopIn(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(iconOf(rating), size: 48, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                rating.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 3; i++)
                    Icon(
                      i < rating.stars ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 36,
                      color: i < rating.stars
                          ? AppColors.warning
                          : theme.colorScheme.outlineVariant,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Score counting up
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: result.score),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, _) => Text(
                  '$value / ${result.total}',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'bonnes réponses',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              if (rewards case final rewards?)
                rewards.isEmpty
                    ? Text(
                        noRewardMessage,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      )
                    : RewardSummaryView(rewards: rewards),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Terminer'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(true),
                      icon: const Icon(Icons.replay),
                      label: const Text('Rejouer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
