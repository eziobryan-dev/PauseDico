import 'alphabet_tier_model.dart';
import 'reward_event_model.dart';

/// Rewards granted by an action (reveal, skip, quiz, bookmark…) and the
/// resulting profile
class RewardSummaryModel {
  final List<RewardEventModel> events;
  final int xp;
  final int level;
  final int nbSkip;
  final int nbWords;
  final int currentStreak;
  final int bookmarkFragments;
  final int bookmarks;
  final AlphabetTier tier;

  const RewardSummaryModel({
    required this.events,
    required this.xp,
    required this.level,
    required this.nbSkip,
    required this.nbWords,
    required this.currentStreak,
    required this.bookmarkFragments,
    required this.bookmarks,
    required this.tier,
  });

  bool get isEmpty => events.isEmpty;

  int get totalXp => events.fold(0, (sum, event) => sum + event.xp);

  int get totalSkips => events.fold(0, (sum, event) => sum + event.skips);

  int get totalFragments => events.fold(0, (sum, event) => sum + event.fragments);

  int get totalBookmarks => events.fold(0, (sum, event) => sum + event.bookmarks);

  bool get hasLevelUp => events.any((event) => event.levelUp);

  RewardEventModel? get wordsMilestone =>
      events.where((event) => event.isWordsMilestone).firstOrNull;

  /// Tier of the first fragment / bookmark found (names it in the popups)
  AlphabetTier get bookmarkTier =>
      events.where((event) => event.fragments > 0).firstOrNull?.tier ?? tier;

  bool get emeraldUnlocked => events.any((event) => event.emeraldUnlocked);

  bool get emeraldCompleted => events.any((event) => event.emeraldCompleted);

  /// Rewards of this action followed by [next]'s (e.g. a reveal then a skip
  /// that unlocks a letter), with the profile figures after [next]
  RewardSummaryModel merge(RewardSummaryModel? next) {
    if (next == null) return this;
    return RewardSummaryModel(
      events: [...events, ...next.events],
      xp: next.xp,
      level: next.level,
      nbSkip: next.nbSkip,
      nbWords: next.nbWords,
      currentStreak: next.currentStreak,
      bookmarkFragments: next.bookmarkFragments,
      bookmarks: next.bookmarks,
      tier: next.tier,
    );
  }

  factory RewardSummaryModel.fromJson(Map<String, dynamic> json) {
    final profile = (json['profile'] as Map<String, dynamic>?) ?? const {};
    return RewardSummaryModel(
      events: ((json['events'] as List?) ?? [])
          .map((event) => RewardEventModel.fromJson(event as Map<String, dynamic>))
          .toList(),
      xp: profile['xp'] as int? ?? 0,
      level: profile['level'] as int? ?? 1,
      nbSkip: profile['nb_skip'] as int? ?? 0,
      nbWords: profile['nb_words'] as int? ?? 0,
      currentStreak: profile['current_streak'] as int? ?? 0,
      bookmarkFragments: profile['bookmark_fragments'] as int? ?? 0,
      bookmarks: profile['bookmarks'] as int? ?? 0,
      tier: AlphabetTier.fromDb(profile['tier'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'events': events.map((event) => event.toJson()).toList(),
      'profile': {
        'xp': xp,
        'level': level,
        'nb_skip': nbSkip,
        'nb_words': nbWords,
        'current_streak': currentStreak,
        'bookmark_fragments': bookmarkFragments,
        'bookmarks': bookmarks,
        'tier': tier.dbValue,
      },
    };
  }
}
