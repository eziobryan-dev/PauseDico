import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/date_helpers.dart';
import '../models/user_word_history_model.dart';

/// A word of the notebook: name, type, learning date and favorite heart
class NotebookEntryTile extends StatelessWidget {
  final UserWordHistoryModel entry;
  final VoidCallback onTap;

  const NotebookEntryTile({super.key, required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final word = entry.word;

    return ListTile(
      onTap: onTap,
      title: Text(
        word.name,
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        [
          if (word.type.isNotEmpty) word.type,
          DateHelpers.formatFrenchDate(entry.date),
        ].join(' · '),
      ),
      trailing: entry.liked
          ? const Icon(Icons.favorite, color: AppColors.danger)
          : null,
    );
  }
}
