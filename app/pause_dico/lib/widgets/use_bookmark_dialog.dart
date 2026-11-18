import 'package:flutter/material.dart';

import '../models/alphabet_tier_model.dart';
import 'letter_tile.dart';

/// "Voulez-vous débloquer cette lettre en utilisant un marque-page ?"
/// Shows the letter as it will look once unlocked: the Alphadex tile, same
/// size, in the current tier's color (gold, or emerald once the gold
/// Alphadex is complete). Returns true when confirmed.
class UseBookmarkDialog extends StatelessWidget {
  final String letter;
  final AlphabetTier tier;
  final int bookmarksLeft;

  /// Size of an Alphadex tile, so that the letter looks the same here
  final Size tileSize;

  const UseBookmarkDialog({
    super.key,
    required this.letter,
    required this.tier,
    required this.bookmarksLeft,
    required this.tileSize,
  });

  static Future<bool> show(
    BuildContext context, {
    required String letter,
    required AlphabetTier tier,
    required int bookmarksLeft,
    required Size tileSize,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => UseBookmarkDialog(
        letter: letter,
        tier: tier,
        bookmarksLeft: bookmarksLeft,
        tileSize: tileSize,
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      // Centered: the dialog would stretch it to its whole width
      icon: Center(
        child: SizedBox.fromSize(
          size: tileSize,
          child: LetterTile(letter: letter, unlocked: true, tier: tier),
        ),
      ),
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
