import 'alphabet_tier_model.dart';

/// One reward granted by the server (e.g. "Série de 30 jours !" +100 xp +1 skip)
class RewardEventModel {
  /// What granted it: reveal, streak, letter, emerald_letter, all_letters,
  /// words_milestone, fragment, ad…
  final String source;
  final String label;
  final int xp;

  /// Skips granted, including +1 every 5 levels
  final int skips;

  /// Bookmark fragments found, and bookmarks assembled from them (7 fragments)
  final int fragments;
  final int bookmarks;

  /// Alphadex stage when granted (names the fragment / bookmark)
  final AlphabetTier tier;
  final bool levelUp;
  final int level;

  /// The discovered letter, for a "new letter" reward
  final String? letter;

  /// Revealed words count, for a "words milestone" reward
  final int? words;

  /// The gold Alphadex was just completed: the emerald one starts
  final bool emeraldUnlocked;

  /// The emerald Alphadex was just completed
  final bool emeraldCompleted;

  const RewardEventModel({
    required this.source,
    required this.label,
    required this.xp,
    required this.skips,
    required this.fragments,
    required this.bookmarks,
    required this.tier,
    required this.levelUp,
    required this.level,
    this.letter,
    this.words,
    this.emeraldUnlocked = false,
    this.emeraldCompleted = false,
  });

  bool get isWordsMilestone => source == 'words_milestone';

  factory RewardEventModel.fromJson(Map<String, dynamic> json) {
    return RewardEventModel(
      source: json['source'] as String? ?? '',
      label: json['label'] as String? ?? '',
      xp: json['xp'] as int? ?? 0,
      skips: json['skips'] as int? ?? 0,
      fragments: json['fragments'] as int? ?? 0,
      bookmarks: json['bookmarks'] as int? ?? 0,
      tier: AlphabetTier.fromDb(json['tier'] as String?),
      levelUp: json['level_up'] as bool? ?? false,
      level: json['level'] as int? ?? 1,
      letter: json['letter'] as String?,
      words: json['words'] as int?,
      emeraldUnlocked: json['emerald_unlocked'] as bool? ?? false,
      emeraldCompleted: json['emerald_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'label': label,
      'xp': xp,
      'skips': skips,
      'fragments': fragments,
      'bookmarks': bookmarks,
      'tier': tier.dbValue,
      'level_up': levelUp,
      'level': level,
      'letter': letter,
      'words': words,
      'emerald_unlocked': emeraldUnlocked,
      'emerald_completed': emeraldCompleted,
    };
  }
}
