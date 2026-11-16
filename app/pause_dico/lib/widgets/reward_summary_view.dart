import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/tier_colors.dart';
import '../models/reward_summary_model.dart';
import '../services/level_service.dart';
import 'fade_in.dart';

/// Rewards just granted: one line per reward (+xp, +skips), fading in one
/// after the other every [rowInterval], and the new level when one was
/// reached. Vibrates once when shown (stronger on a level up).
class RewardSummaryView extends StatefulWidget {
  final RewardSummaryModel rewards;
  final Duration rowInterval;

  const RewardSummaryView({
    super.key,
    required this.rewards,
    this.rowInterval = const Duration(milliseconds: 200),
  });

  @override
  State<RewardSummaryView> createState() => _RewardSummaryViewState();
}

class _RewardSummaryViewState extends State<RewardSummaryView> {
  @override
  void initState() {
    super.initState();
    if (widget.rewards.hasLevelUp) {
      HapticFeedback.heavyImpact();
    } else if (!widget.rewards.isEmpty) {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rewards = widget.rewards;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < rewards.events.length; i++)
            FadeIn(
              delay: widget.rowInterval * i,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        rewards.events[i].label,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    if (rewards.events[i].xp > 0)
                      _Gain(label: '+${rewards.events[i].xp} XP', color: AppColors.info),
                    if (rewards.events[i].skips > 0) ...[
                      const SizedBox(width: 6),
                      _Gain(
                        label: '+${rewards.events[i].skips} skip'
                            '${rewards.events[i].skips > 1 ? 's' : ''}',
                        color: AppColors.success,
                      ),
                    ],
                    if (rewards.events[i].fragments > 0) ...[
                      const SizedBox(width: 6),
                      _Gain(
                        label: '+${rewards.events[i].fragments} fragment'
                            '${rewards.events[i].fragments > 1 ? 's' : ''}',
                        color: TierColors.dark(rewards.events[i].tier),
                      ),
                    ],
                    if (rewards.events[i].bookmarks > 0) ...[
                      const SizedBox(width: 6),
                      _Gain(
                        label: '+${rewards.events[i].bookmarks} marque-page',
                        color: TierColors.dark(rewards.events[i].tier),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          if (rewards.hasLevelUp)
            FadeIn(
              delay: widget.rowInterval * rewards.events.length,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '⬆️ Niveau ${rewards.level} · ${LevelService.titleFor(rewards.level)} !',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.tertiary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Gain extends StatelessWidget {
  final String label;
  final Color color;

  const _Gain({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
