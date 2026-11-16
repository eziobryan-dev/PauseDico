import 'package:flutter/material.dart';

/// Space reserved for an ad. Placeholder until an ad provider is wired in:
/// the provider's banner view will replace the label.
class AdSlot extends StatelessWidget {
  const AdSlot({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 6,
            left: 10,
            child: Text(
              'Publicité',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Center(
            child: Icon(
              Icons.campaign_outlined,
              size: 32,
              color: colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
