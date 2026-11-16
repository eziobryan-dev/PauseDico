import 'package:flutter/material.dart';

import '../models/alphabet_tier_model.dart';
import 'bookmark_art.dart';

/// "Voulez-vous débloquer cette lettre en utilisant un marque-page ?"
/// Returns true when confirmed.
class UseBookmarkDialog extends StatelessWidget {
  final String letter;
  final AlphabetTier tier;
  final int bookmarksLeft;

  const UseBookmarkDialog({
    super.key,
    required this.letter,
    required this.tier,
    required this.bookmarksLeft,
  });

  static Future<bool> show(
    BuildContext context, {
    required String letter,
    required AlphabetTier tier,
    required int bookmarksLeft,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => UseBookmarkDialog(
        letter: letter,
        tier: tier,
        bookmarksLeft: bookmarksLeft,
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      icon: BookmarkArt(tier: tier, size: 64),
      title: Text('Lettre $letter'),
      content: Text(
        'Voulez-vous débloquer cette lettre en utilisant un ${tier.bookmarkName} ?\n\n'
        'Il vous en reste $bookmarksLeft.',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyLarge,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Débloquer'),
        ),
      ],
    );
  }
}
