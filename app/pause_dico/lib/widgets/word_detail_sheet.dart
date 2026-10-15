import 'package:flutter/material.dart';

import '../models/word_model.dart';
import 'word_card.dart';

/// Bottom sheet showing a learned word's card (like, share, listen…)
class WordDetailSheet extends StatelessWidget {
  final WordModel word;
  final bool liked;
  final Future<bool> Function(bool liked) onLikeChanged;

  const WordDetailSheet({
    super.key,
    required this.word,
    required this.liked,
    required this.onLikeChanged,
  });

  static Future<void> show(
    BuildContext context, {
    required WordModel word,
    required bool liked,
    required Future<bool> Function(bool liked) onLikeChanged,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => WordDetailSheet(
        word: word,
        liked: liked,
        onLikeChanged: onLikeChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: WordCard(word: word, liked: liked, onLikeChanged: onLikeChanged),
      ),
    );
  }
}
