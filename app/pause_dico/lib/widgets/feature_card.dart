import 'package:flutter/material.dart';

enum FeatureCardTone { tertiary, error }

/// Centered card with an icon, an optional title, a message and an action button
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String? title;
  final String message;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback? onAction;
  final FeatureCardTone tone;

  const FeatureCard({
    super.key,
    required this.icon,
    this.title,
    required this.message,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
    this.tone = FeatureCardTone.tertiary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isError = tone == FeatureCardTone.error;

    final background =
        isError ? colorScheme.errorContainer : colorScheme.tertiaryContainer;
    final accent = isError ? colorScheme.error : colorScheme.tertiary;
    final onAccent = isError ? colorScheme.onError : colorScheme.onTertiary;
    final onBackground = isError
        ? colorScheme.onErrorContainer
        : colorScheme.onTertiaryContainer;

    return Card(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: accent.withValues(alpha: 0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(icon, size: 48, color: accent),
            const SizedBox(height: 12),
            if (title != null) ...[
              Text(
                title!,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: onBackground,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: onBackground.withValues(alpha: 0.9)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: onAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: onAction,
              icon: Icon(actionIcon),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
