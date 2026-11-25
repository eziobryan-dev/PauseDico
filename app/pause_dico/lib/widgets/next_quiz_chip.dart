import 'package:flutter/material.dart';

/// Small tappable pill "Prochain quiz / dans x jours", shown in place of the
/// "next day" arrow on today's word
class NextQuizChip extends StatelessWidget {
  /// Days until the weekly quiz (0: today)
  final int daysLeft;
  final VoidCallback onTap;

  const NextQuizChip({super.key, required this.daysLeft, required this.onTap});

  static String delayLabel(int daysLeft) => switch (daysLeft) {
        0 => "aujourd'hui",
        1 => 'demain',
        _ => 'dans $daysLeft jours',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    final small = theme.textTheme.labelSmall;

    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, size: 16, color: color),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Prochain quiz', style: small?.copyWith(color: color)),
                  Text(
                    delayLabel(daysLeft),
                    style: small?.copyWith(color: color, fontWeight: FontWeight.bold),
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
