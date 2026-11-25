import 'package:flutter/material.dart';

/// Bottom sheet explaining something: a title and a list of [InfoSheetRow]
class InfoSheet extends StatelessWidget {
  final String title;
  final List<Widget> rows;

  const InfoSheet({super.key, required this.title, required this.rows});

  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<Widget> rows,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => InfoSheet(title: title, rows: rows),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            for (final row in rows)
              Padding(padding: const EdgeInsets.only(bottom: 16), child: row),
          ],
        ),
      ),
    );
  }
}

/// One explanation of an [InfoSheet]: an icon (or drawing), a title and a text
class InfoSheetRow extends StatelessWidget {
  final IconData? icon;

  /// Drawing shown instead of [icon]
  final Widget? art;
  final Color color;
  final String title;
  final String description;

  const InfoSheetRow({
    super.key,
    this.icon,
    this.art,
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: art ?? Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
