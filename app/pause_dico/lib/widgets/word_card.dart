import 'package:flutter/material.dart';

import '../models/word_model.dart';
import '../services/pronunciation_service.dart';
import '../services/word_share_service.dart';
import 'like_button.dart';
import 'wiktionary_link.dart';

/// Card showing a word and its definition.
/// Shows a like heart in the top-right corner when [onLikeChanged] is set.
class WordCard extends StatelessWidget {
  final WordModel word;
  final bool liked;
  final Future<bool> Function(bool liked)? onLikeChanged;

  const WordCard({
    super.key,
    required this.word,
    this.liked = false,
    this.onLikeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        word.name,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (word.type.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          word.type,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onLikeChanged != null)
                  LikeButton(liked: liked, onChanged: onLikeChanged!),
              ],
            ),
            const Divider(height: 32),
            Text(
              'Définition',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(word.definition, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  tooltip: 'Écouter',
                  icon: const Icon(Icons.volume_up_rounded),
                  onPressed: () => PronunciationService.speak(word.name),
                ),
                IconButton(
                  tooltip: 'Partager',
                  icon: const Icon(Icons.share_rounded),
                  onPressed: () => WordShareService.share(word),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: WiktionaryLink(wordName: word.name),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
