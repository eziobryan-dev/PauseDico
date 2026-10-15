import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/user_game_profile_model.dart';
import '../services/level_service.dart';

/// Profile card: level and title, xp progress, streak, skips and letters
class LevelCard extends StatelessWidget {
  final UserGameProfileModel profile;

  const LevelCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMaxLevel = profile.level >= LevelService.maxLevel;
    final streak = profile.activeStreak(DateTime.now());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    '${profile.level}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LevelService.titleFor(profile.level),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        isMaxLevel
                            ? 'Niveau maximum atteint'
                            : 'Niveau ${profile.level} · encore '
                                '${LevelService.xpToNextLevel(profile.xp, profile.level)} XP',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: LevelService.progress(profile.xp, profile.level),
                minHeight: 10,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Stat(
                  icon: Icons.local_fire_department,
                  label: '$streak jour${streak > 1 ? 's' : ''} (record: ${profile.bestStreak})',
                  color: AppColors.tertiary,
                ),
                _Stat(
                  icon: Icons.replay,
                  label: '${profile.nbSkip} skip${profile.nbSkip > 1 ? 's' : ''}',
                  color: AppColors.success,
                ),
                _Stat(
                  icon: Icons.abc,
                  label: '${profile.lettersCount} / 26 lettres dorées',
                  color: AppColors.warning,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Stat({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
