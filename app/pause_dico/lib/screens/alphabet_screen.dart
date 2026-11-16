import 'package:flutter/material.dart';

import '../core/theme/tier_colors.dart';
import '../core/utils/context_extensions.dart';
import '../core/utils/date_helpers.dart';
import '../models/user_game_profile_model.dart';
import '../models/word_model.dart';
import '../repositories/user_game_profile_repository.dart';
import '../repositories/user_word_history_repository.dart';
import '../widgets/emerald_alphadex_view.dart';
import '../widgets/letter_tile.dart';
import '../widgets/use_bookmark_dialog.dart';
import '../widgets/letter_words_sheet.dart';
import '../widgets/screen_title.dart';

/// Alphabet collection: a letter turns gold once a word starting with it was
/// discovered (or a golden bookmark was used on it). Once the 26 are gold,
/// the emerald Alphadex starts over. Read from the profile (a single row).
class AlphabetScreen extends StatefulWidget {
  const AlphabetScreen({super.key});

  @override
  State<AlphabetScreen> createState() => _AlphabetScreenState();
}

class _AlphabetScreenState extends State<AlphabetScreen> {
  static const _columns = 4;

  /// 7 rows of 4: A..X, then Y and Z centered on the last row
  static final List<String?> _slots = [
    for (var i = 0; i < 24; i++) String.fromCharCode('A'.codeUnitAt(0) + i),
    null,
    'Y',
    'Z',
    null,
  ];

  final UserGameProfileRepository _profileRepository = UserGameProfileRepository();
  final UserWordHistoryRepository _historyRepository = UserWordHistoryRepository();

  UserGameProfileModel? _profile;
  bool _isLoading = true;

  /// Words per letter, loaded once: the sheet opens already at its final size
  final Map<String, List<WordModel>> _wordsByLetter = {};
  String? _loadingLetter;
  bool _isUsingBookmark = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileRepository.getProfile();
      if (mounted) setState(() => _profile = profile);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Loads the letter's words first, then opens the sheet: it slides up from
  /// the bottom directly at its final size (no loader-to-list resize)
  Future<void> _showLetterWords(String letter) async {
    if (_loadingLetter != null) return;

    var words = _wordsByLetter[letter];
    if (words == null) {
      setState(() => _loadingLetter = letter);
      try {
        words = await _historyRepository.getWordsByLetter(letter);
        _wordsByLetter[letter] = words;
      } catch (e) {
        if (mounted) context.showSnackBar('Impossible de charger les mots.');
        return;
      } finally {
        if (mounted) setState(() => _loadingLetter = null);
      }
    }

    if (!mounted) return;
    LetterWordsSheet.show(
      context,
      letter: letter,
      words: words,
      bookmarkTier: _profile?.hasBookmarkLetter(letter) ?? false ? _profile!.tier : null,
    );
  }

  /// Locked letter + a bookmark: confirm, then unlock it on the server
  Future<void> _useBookmark(String letter) async {
    final profile = _profile;
    if (profile == null || _isUsingBookmark) return;

    final confirmed = await UseBookmarkDialog.show(
      context,
      letter: letter,
      tier: profile.tier,
      bookmarksLeft: profile.bookmarks,
    );
    if (!confirmed || !mounted) return;

    setState(() => _isUsingBookmark = true);
    try {
      final rewards = await _profileRepository.useBookmark(
        DateHelpers.dateOnly(DateTime.now()),
        letter,
      );
      final updated = await _profileRepository.getProfile();
      if (!mounted) return;
      setState(() => _profile = updated ?? profile);
      context.showSnackBar('Lettre $letter débloquée ! +${rewards.totalXp} XP');
      if (rewards.emeraldUnlocked || rewards.emeraldCompleted) {
        await EmeraldAlphadexView.show(context, completed: rewards.emeraldCompleted);
      }
    } catch (e) {
      if (mounted) context.showSnackBar('Impossible de débloquer la lettre.');
    } finally {
      if (mounted) setState(() => _isUsingBookmark = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const ScreenTitle('Alphadex')),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final profile = _profile;
    if (profile == null) {
      return const Center(child: Text("Impossible de charger l'Alphadex."));
    }

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          Text(
            profile.hasAllLetters
                ? '${profile.tier.alphadexName} complet ! 🏆'
                : '${profile.lettersCount} / 26 lettres ${profile.tier.femininePlural}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: TierColors.dark(profile.tier),
            ),
          ),
          Text(
            profile.bookmarks > 0
                ? 'Touche une lettre grise pour la débloquer avec un '
                    '${profile.tier.bookmarkName} (${profile.bookmarks})'
                : 'Touche une lettre ${profile.tier.feminine} pour voir tes mots',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          // Same height whether loading or not: no layout shift
          SizedBox(
            height: 16,
            child: _loadingLetter == null && !_isUsingBookmark
                ? null
                : const Center(child: LinearProgressIndicator(minHeight: 2)),
          ),
          Expanded(
            child: Column(
              children: [
                for (var row = 0; row < _slots.length ~/ _columns; row++)
                  Expanded(
                    child: Row(
                      children: [
                        for (var col = 0; col < _columns; col++)
                          Expanded(child: _buildSlot(_slots[row * _columns + col], profile)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlot(String? letter, UserGameProfileModel profile) {
    if (letter == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(8),
      child: LetterTile(
        letter: letter,
        unlocked: profile.hasLetter(letter),
        tier: profile.tier,
        onTap: () => _showLetterWords(letter),
        onUseBookmark: profile.bookmarks > 0 ? () => _useBookmark(letter) : null,
      ),
    );
  }
}
