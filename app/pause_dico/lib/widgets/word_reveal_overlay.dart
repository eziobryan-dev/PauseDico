import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/daily_word_reveal_model.dart';
import 'error_banner.dart';
import 'pop_in.dart';
import 'reward_summary_view.dart';
import 'skip_word_button.dart';
import 'word_card.dart';

/// Full-screen dark overlay animating the entrance of the daily word,
/// with "OK !" and "Je veux un autre mot" buttons below the card.
class WordRevealOverlay extends StatefulWidget {
  final DailyWordRevealModel initialReveal;
  final Future<DailyWordRevealModel> Function() onSkip;
  final Future<bool> Function(int wordId, bool liked) onLikeChanged;

  const WordRevealOverlay({
    super.key,
    required this.initialReveal,
    required this.onSkip,
    required this.onLikeChanged,
  });

  /// Shows the overlay and returns the word kept by the user
  static Future<DailyWordRevealModel?> show(
    BuildContext context, {
    required DailyWordRevealModel reveal,
    required Future<DailyWordRevealModel> Function() onSkip,
    required Future<bool> Function(int wordId, bool liked) onLikeChanged,
  }) {
    return showGeneralDialog<DailyWordRevealModel>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, _, _) => WordRevealOverlay(
        initialReveal: reveal,
        onSkip: onSkip,
        onLikeChanged: onLikeChanged,
      ),
    );
  }

  @override
  State<WordRevealOverlay> createState() => _WordRevealOverlayState();
}

class _WordRevealOverlayState extends State<WordRevealOverlay> {
  late DailyWordRevealModel _reveal = widget.initialReveal;
  bool _isSkipping = false;
  String? _errorMessage;

  Future<void> _skip() async {
    setState(() {
      _isSkipping = true;
      _errorMessage = null;
    });

    try {
      final reveal = await widget.onSkip();
      if (mounted) setState(() => _reveal = reveal);
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Impossible de changer de mot.');
      }
    } finally {
      if (mounted) setState(() => _isSkipping = false);
    }
  }

  Future<bool> _setLiked(bool liked) async {
    final wordId = _reveal.word.id;
    final saved = await widget.onLikeChanged(wordId, liked);
    // Ignore the result if the word was skipped meanwhile
    if (mounted && _reveal.word.id == wordId) {
      setState(() => _reveal = _reveal.copyWith(liked: saved));
    }
    return saved;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PopIn(
                  key: ValueKey(_reveal.word.id),
                  child: WordCard(
                    word: _reveal.word,
                    liked: _reveal.liked,
                    onLikeChanged: _setLiked,
                  ),
                ),
                const SizedBox(height: 24),
                if (_reveal.rewards case final rewards? when !rewards.isEmpty) ...[
                  RewardSummaryView(
                    // Sibling of the card's PopIn: needs its own key, still
                    // per word so it replays after a skip
                    key: ValueKey(('rewards', _reveal.word.id)),
                    rewards: rewards,
                  ),
                  const SizedBox(height: 16),
                ],
                if (_errorMessage != null) ...[
                  ErrorBanner(message: _errorMessage!),
                  const SizedBox(height: 12),
                ],
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isSkipping
                      ? null
                      : () => Navigator.of(context).pop(_reveal),
                  child: const Text('OK !'),
                ),
                const SizedBox(height: 12),
                SkipWordButton(
                  skipsLeft: _reveal.skipsLeft,
                  onPressed: _isSkipping ? null : _skip,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
