import 'package:flutter/material.dart';

import '../models/word_model.dart';

/// Bottom sheet listing the discovered words starting with a letter.
/// The words are loaded before opening, so the sheet slides up from the
/// bottom directly at its final size.
class LetterWordsSheet extends StatelessWidget {
  final String letter;
  final List<WordModel> words;

  const LetterWordsSheet({super.key, required this.letter, required this.words});

  static Future<void> show(
    BuildContext context, {
    required String letter,
    required List<WordModel> words,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => LetterWordsSheet(letter: letter, words: words),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Lettre $letter · ${words.length} mot${words.length > 1 ? 's' : ''}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: words.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) => ListTile(
                title: Text(
                  words[i].name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  words[i].definition,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  words[i].theme,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
