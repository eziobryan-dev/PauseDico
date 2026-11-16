import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/tier_colors.dart';
import '../models/alphabet_tier_model.dart';
import '../models/user_game_profile_model.dart';
import '../services/level_service.dart';
import 'bookmark_art.dart';

/// Profile card: level and title, xp progress, streak, skips, words unlocked,
/// letters, bookmark fragments and bookmarks (named after the Alphadex tier)
class LevelCard extends StatelessWidget {
  final UserGameProfileModel profile;

  const LevelCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMaxLevel = profile.level >= LevelService.maxLevel;
    final streak = profile.activeStreak(DateTime.now());
    final tier = profile.tier;

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
                  icon: Icons.menu_book_rounded,
                  label: '${profile.nbWords} mot${profile.nbWords > 1 ? 's' : ''} '
                      'débloqué${profile.nbWords > 1 ? 's' : ''}',
                  color: AppColors.info,
                ),
                _Stat(
                  icon: Icons.abc,
                  label: '${profile.lettersCount} / 26 lettres ${tier.femininePlural}',
                  color: TierColors.dark(tier),
                ),
                _Stat(
                  art: BookmarkArt.fragment(tier: tier, size: 18),
                  label: '${profile.bookmarkFragments} / ${AppConstants.fragmentsPerBookmark} '
                      'fragments',
                  color: TierColors.dark(tier),
                ),
                _Stat(
                  art: BookmarkArt(tier: tier, size: 18),
                  label: '${profile.bookmarks} marque-page'
                      '${profile.bookmarks > 1 ? 's' : ''} ${tier.masculine}'
                      '${profile.bookmarks > 1 && tier == AlphabetTier.gold ? 's' : ''}',
                  color: TierColors.dark(tier),
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
  final IconData? icon;

  /// Drawing shown instead of [icon]
  final Widget? art;
  final String label;
  final Color color;

  const _Stat({this.icon, this.art, required this.label, required this.color});

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
          art ?? Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
