import 'package:flutter/material.dart';

import '../models/daily_word_reveal_model.dart';
import '../models/reward_summary_model.dart';
import 'bookmark_assembled_step.dart';
import 'emerald_alphadex_view.dart';
import 'fade_in.dart';
import 'fragment_found_step.dart';
import 'green_action_button.dart';
import 'pop_in.dart';
import 'reward_summary_view.dart';
import 'word_card.dart';
import 'words_milestone_step.dart';

/// Steps of the reveal overlay, after the word card (each one optional)
enum _RevealStep { milestone, fragment, bookmark, rewards, emerald }

/// Full-screen dark overlay revealing the chosen daily word:
/// 1. the word's card pops in with its definition, and "Suivant";
/// 2. one popup per highlight: words milestone, bookmark fragment found,
///    bookmark assembled;
/// 3. the rewards earned fade in one row per second;
/// 4. the emerald Alphadex congratulations, if the gold one was just completed.
/// Without anything to show, "Suivant" closes it directly.
class WordRevealOverlay extends StatefulWidget {
  final DailyWordRevealModel initialReveal;
  final Future<bool> Function(int wordId, bool liked) onLikeChanged;

  const WordRevealOverlay({
    super.key,
    required this.initialReveal,
    required this.onLikeChanged,
  });

  /// Shows the overlay and returns the word (with its like state)
  static Future<DailyWordRevealModel?> show(
    BuildContext context, {
    required DailyWordRevealModel reveal,
    required Future<bool> Function(int wordId, bool liked) onLikeChanged,
  }) {
    return showGeneralDialog<DailyWordRevealModel>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, _, _) => WordRevealOverlay(
        initialReveal: reveal,
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

  /// Steps left after the word card, the current one first (empty: word card)
  List<_RevealStep> _steps = const [];

  Future<bool> _setLiked(bool liked) async {
    final saved = await widget.onLikeChanged(_reveal.word.id, liked);
    if (mounted) setState(() => _reveal = _reveal.copyWith(liked: saved));
    return saved;
  }

  /// Word card -> the steps worth showing, or close when there is none
  void _continueFromWord() {
    final rewards = _reveal.rewards;
    final steps = rewards == null || rewards.isEmpty
        ? <_RevealStep>[]
        : [
            if (rewards.wordsMilestone != null) _RevealStep.milestone,
            if (rewards.totalFragments > 0) _RevealStep.fragment,
            if (rewards.totalBookmarks > 0) _RevealStep.bookmark,
            _RevealStep.rewards,
            if (rewards.emeraldUnlocked || rewards.emeraldCompleted) _RevealStep.emerald,
          ];
    if (steps.isEmpty) {
      _close();
    } else {
      setState(() => _steps = steps);
    }
  }

  void _nextStep() {
    if (_steps.length <= 1) {
      _close();
    } else {
      setState(() => _steps = _steps.sublist(1));
    }
  }

  void _close() => Navigator.of(context).pop(_reveal);

  @override
  Widget build(BuildContext context) {
    final step = _steps.firstOrNull;
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: KeyedSubtree(
                key: ValueKey(step),
                child: step == null ? _buildWordStep() : _buildStep(step),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(_RevealStep step) {
    final rewards = _reveal.rewards!;
    return switch (step) {
      _RevealStep.milestone => WordsMilestoneStep(
          words: rewards.wordsMilestone?.words ?? rewards.nbWords,
          onContinue: _nextStep,
        ),
      _RevealStep.fragment => FragmentFoundStep(
          tier: rewards.bookmarkTier,
          count: rewards.totalFragments,
          fragmentsHeld: rewards.totalBookmarks > 0 ? null : rewards.bookmarkFragments,
          onContinue: _nextStep,
        ),
      _RevealStep.bookmark => BookmarkAssembledStep(
          tier: rewards.bookmarkTier,
          onContinue: _nextStep,
        ),
      _RevealStep.rewards => _buildRewardsStep(rewards),
      _RevealStep.emerald => EmeraldAlphadexView(
          completed: rewards.emeraldCompleted,
          onContinue: _nextStep,
        ),
    };
  }

  Widget _buildWordStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PopIn(
          child: WordCard(
            word: _reveal.word,
            liked: _reveal.liked,
            onLikeChanged: _setLiked,
          ),
        ),
        const SizedBox(height: 24),
        GreenActionButton(label: 'Suivant', onPressed: _continueFromWord),
      ],
    );
  }

  Widget _buildRewardsStep(RewardSummaryModel rewards) {
    final theme = Theme.of(context);
    final isLast = _steps.length <= 1;

    return Column(
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
        GreenActionButton(label: isLast ? 'Merci !' : 'Continuer', onPressed: _nextStep),
      ],
    );
  }
}
