import 'package:flutter/material.dart';

import '../models/daily_word_reveal_model.dart';
import '../models/reward_summary_model.dart';
import 'bookmark_assembled_step.dart';
import 'emerald_alphadex_view.dart';
import 'error_banner.dart';
import 'fade_in.dart';
import 'fragment_found_step.dart';
import 'green_action_button.dart';
import 'pop_in.dart';
import 'reward_summary_view.dart';
import 'rewarded_skip_button.dart';
import 'skip_word_button.dart';
import 'word_card.dart';
import 'words_milestone_step.dart';

/// Steps of the reveal overlay, after the word card (each one optional)
enum _RevealStep { milestone, fragment, bookmark, rewards, emerald }

/// Full-screen dark overlay revealing the daily word:
/// 1. the word's card pops in, with "Valider ce mot" and "Je veux un autre mot";
/// 2. once validated, one popup per highlight: words milestone, bookmark
///    fragment found, bookmark assembled;
/// 3. the rewards earned fade in one row per second;
/// 4. the emerald Alphadex congratulations, if the gold one was just completed.
/// Without anything to show, "Valider ce mot" closes it directly.
class WordRevealOverlay extends StatefulWidget {
  final DailyWordRevealModel initialReveal;
  final Future<DailyWordRevealModel> Function() onSkip;
  final Future<bool> Function(int wordId, bool liked) onLikeChanged;

  /// Without skips left: whether a rewarded ad can give one, and the action
  /// showing it (null when the ad was not watched until the reward)
  final Future<bool> Function() canWatchAdForSkip;
  final Future<RewardSummaryModel?> Function() onWatchAdForSkip;

  const WordRevealOverlay({
    super.key,
    required this.initialReveal,
    required this.onSkip,
    required this.onLikeChanged,
    required this.canWatchAdForSkip,
    required this.onWatchAdForSkip,
  });

  /// Shows the overlay and returns the word kept by the user
  static Future<DailyWordRevealModel?> show(
    BuildContext context, {
    required DailyWordRevealModel reveal,
    required Future<DailyWordRevealModel> Function() onSkip,
    required Future<bool> Function(int wordId, bool liked) onLikeChanged,
    required Future<bool> Function() canWatchAdForSkip,
    required Future<RewardSummaryModel?> Function() onWatchAdForSkip,
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
        canWatchAdForSkip: canWatchAdForSkip,
        onWatchAdForSkip: onWatchAdForSkip,
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

  /// Steps left after the word card, the current one first (empty: word card)
  List<_RevealStep> _steps = const [];

  bool _isSkipping = false;
  bool _canWatchAd = false;
  bool _isWatchingAd = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _refreshCanWatchAd();
  }

  /// The rewarded ad is only offered once the skips are used up
  Future<void> _refreshCanWatchAd() async {
    if (_reveal.skipsLeft > 0) return;
    try {
      final canWatch = await widget.canWatchAdForSkip();
      if (mounted) setState(() => _canWatchAd = canWatch);
    } catch (e) {
      // Not blocking: no ad offered
    }
  }

  Future<void> _watchAdForSkip() async {
    setState(() {
      _isWatchingAd = true;
      _errorMessage = null;
    });

    try {
      final rewards = await widget.onWatchAdForSkip();
      if (!mounted) return;
      setState(() {
        if (rewards == null) {
          _errorMessage = 'Pub indisponible ou interrompue : pas de skip cette fois.';
        } else {
          _reveal = _reveal.copyWith(skipsLeft: rewards.nbSkip);
          _rewards = _rewards?.merge(rewards) ?? rewards;
          _canWatchAd = false;
        }
      });
    } catch (e) {
      if (mounted) setState(() => _errorMessage = "Impossible d'obtenir le skip.");
    } finally {
      if (mounted) setState(() => _isWatchingAd = false);
    }
  }

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
      _refreshCanWatchAd();
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

  /// Word card -> the steps worth showing, or close when there is none
  void _validateWord() {
    final rewards = _rewards;
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
    final rewards = _rewards!;
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
        GreenActionButton(
          label: 'Valider ce mot',
          onPressed: _isSkipping || _isWatchingAd ? null : _validateWord,
        ),
        const SizedBox(height: 12),
        SkipWordButton(
          skipsLeft: _reveal.skipsLeft,
          onPressed: _isSkipping ? null : _skip,
        ),
        if (_reveal.skipsLeft == 0 && _canWatchAd) ...[
          const SizedBox(height: 4),
          RewardedSkipButton(
            isBusy: _isWatchingAd,
            onPressed: _isSkipping ? null : _watchAdForSkip,
          ),
        ],
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
