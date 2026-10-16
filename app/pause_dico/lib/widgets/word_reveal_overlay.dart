import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/daily_word_reveal_model.dart';
import '../models/reward_summary_model.dart';
import 'error_banner.dart';
import 'fade_in.dart';
import 'pop_in.dart';
import 'reward_summary_view.dart';
import 'skip_word_button.dart';
import 'word_card.dart';

/// Full-screen dark overlay revealing the daily word, in two steps:
/// 1. the word's card pops in, with "Valider ce mot" and "Je veux un autre mot";
/// 2. once validated, the rewards earned (reveal, streak, letters…) fade in
///    one row per second, and "Merci !" closes the overlay.
/// Without rewards, "Valider ce mot" closes it directly.
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
  static const _rewardRowInterval = Duration(seconds: 1);

  late DailyWordRevealModel _reveal = widget.initialReveal;

  /// Everything earned since the reveal (a skip can unlock a letter too)
  late RewardSummaryModel? _rewards = widget.initialReveal.rewards;

  bool _isSkipping = false;
  bool _showsRewards = false;
  String? _errorMessage;

  Future<void> _skip() async {
    setState(() {
      _isSkipping = true;
      _errorMessage = null;
    });

    try {
      final reveal = await widget.onSkip();
      if (!mounted) return;
      setState(() {
        _reveal = reveal;
        _rewards = _rewards?.merge(reveal.rewards) ?? reveal.rewards;
      });
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

  /// Step 1 -> step 2 (rewards), or close when there is nothing to show
  void _validateWord() {
    final rewards = _rewards;
    if (rewards == null || rewards.isEmpty) {
      _close();
    } else {
      setState(() => _showsRewards = true);
    }
  }

  void _close() => Navigator.of(context).pop(_reveal);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _showsRewards ? _buildRewardsStep() : _buildWordStep(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWordStep() {
    return Column(
      key: const ValueKey('word-step'),
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
        if (_errorMessage != null) ...[
          ErrorBanner(message: _errorMessage!),
          const SizedBox(height: 12),
        ],
        _GreenButton(
          label: 'Valider ce mot',
          onPressed: _isSkipping ? null : _validateWord,
        ),
        const SizedBox(height: 12),
        SkipWordButton(
          skipsLeft: _reveal.skipsLeft,
          onPressed: _isSkipping ? null : _skip,
        ),
      ],
    );
  }

  Widget _buildRewardsStep() {
    final rewards = _rewards!;
    final theme = Theme.of(context);

    return Column(
      key: const ValueKey('rewards-step'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FadeIn(
          child: Text(
            'Récompenses',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 16),
        RewardSummaryView(rewards: rewards, rowInterval: _rewardRowInterval),
        const SizedBox(height: 24),
        _GreenButton(label: 'Merci !', onPressed: _close),
      ],
    );
  }
}

/// Full-width green call-to-action of the reveal overlay
class _GreenButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _GreenButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
