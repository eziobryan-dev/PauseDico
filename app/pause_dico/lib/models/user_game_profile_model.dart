import '../core/utils/date_helpers.dart';
import 'alphabet_tier_model.dart';

class UserGameProfileModel {
  static const _allLettersMask = (1 << 26) - 1;

  final String userId;
  final int level;
  final int xp;

  /// Words revealed since the account was created (skipped ones excluded)
  final int nbWords;
  final int nbQuizWeeklyCompleted;
  final int nbQuizMonthlyCompleted;
  final int nbQuizYearlyCompleted;
  final int nbSkip;
  final int currentStreak;
  final int bestStreak;
  final DateTime? lastRevealDate;

  /// One bit per letter (bit 0 = A … bit 25 = Z). Gold letters come from the
  /// history words ([lettersMask]) or from bookmarks ([goldBookmarkMask]).
  final int lettersMask;
  final int goldBookmarkMask;

  /// Day the gold Alphadex was completed: the emerald one started after it
  final DateTime? emeraldSince;

  /// Emerald letters: from words revealed after [emeraldSince], or bookmarks
  final int emeraldMask;
  final int emeraldBookmarkMask;

  final int bookmarkFragments;
  final int bookmarks;

  const UserGameProfileModel({
    required this.userId,
    required this.level,
    required this.xp,
    required this.nbWords,
    required this.nbQuizWeeklyCompleted,
    required this.nbQuizMonthlyCompleted,
    required this.nbQuizYearlyCompleted,
    required this.nbSkip,
    required this.currentStreak,
    required this.bestStreak,
    required this.lastRevealDate,
    required this.lettersMask,
    required this.goldBookmarkMask,
    required this.emeraldSince,
    required this.emeraldMask,
    required this.emeraldBookmarkMask,
    required this.bookmarkFragments,
    required this.bookmarks,
  });

  AlphabetTier get tier =>
      emeraldSince == null ? AlphabetTier.gold : AlphabetTier.emerald;

  /// Letters unlocked in the current tier
  int get activeMask => tier == AlphabetTier.gold
      ? lettersMask | goldBookmarkMask
      : emeraldMask | emeraldBookmarkMask;

  int get _activeBookmarkMask =>
      tier == AlphabetTier.gold ? goldBookmarkMask : emeraldBookmarkMask;

  /// The streak still counts if the last reveal was today or yesterday, or on
  /// Saturday when yesterday was Sunday (quiz day, no daily word)
  int activeStreak(DateTime today) {
    final last = lastRevealDate;
    if (last == null) return 0;
    final daysSince = DateHelpers.daysBetween(last, today);
    final yesterdayWasSunday =
        DateHelpers.addDays(today, -1).weekday == DateTime.sunday;
    return daysSince <= 1 || (daysSince == 2 && yesterdayWasSunday)
        ? currentStreak
        : 0;
  }

  static int _bit(String letter) =>
      1 << (letter.codeUnitAt(0) - 'A'.codeUnitAt(0));

  /// Unlocked in the current tier
  bool hasLetter(String letter) => activeMask & _bit(letter) != 0;

  /// Unlocked with a bookmark in the current tier
  bool hasBookmarkLetter(String letter) => _activeBookmarkMask & _bit(letter) != 0;

  int get lettersCount => List.generate(26, (i) => activeMask >> i & 1)
      .fold(0, (sum, bit) => sum + bit);

  bool get hasAllLetters => activeMask == _allLettersMask;

  factory UserGameProfileModel.fromJson(Map<String, dynamic> json) {
    final lastRevealDate = json['last_reveal_date'] as String?;
    final emeraldSince = json['emerald_since'] as String?;
    return UserGameProfileModel(
      userId: json['user_id'] as String,
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      nbWords: json['nb_words'] as int? ?? 0,
      nbQuizWeeklyCompleted: json['nb_quiz_weekly_completed'] as int? ?? 0,
      nbQuizMonthlyCompleted: json['nb_quiz_monthly_completed'] as int? ?? 0,
      nbQuizYearlyCompleted: json['nb_quiz_yearly_completed'] as int? ?? 0,
      nbSkip: json['nb_skip'] as int? ?? 0,
      currentStreak: json['current_streak'] as int? ?? 0,
      bestStreak: json['best_streak'] as int? ?? 0,
      lastRevealDate:
          lastRevealDate == null ? null : DateTime.parse(lastRevealDate),
      lettersMask: json['letters_mask'] as int? ?? 0,
      goldBookmarkMask: json['gold_bookmark_mask'] as int? ?? 0,
      emeraldSince: emeraldSince == null ? null : DateTime.parse(emeraldSince),
      emeraldMask: json['emerald_mask'] as int? ?? 0,
      emeraldBookmarkMask: json['emerald_bookmark_mask'] as int? ?? 0,
      bookmarkFragments: json['bookmark_fragments'] as int? ?? 0,
      bookmarks: json['bookmarks'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'level': level,
      'xp': xp,
      'nb_words': nbWords,
      'nb_quiz_weekly_completed': nbQuizWeeklyCompleted,
      'nb_quiz_monthly_completed': nbQuizMonthlyCompleted,
      'nb_quiz_yearly_completed': nbQuizYearlyCompleted,
      'nb_skip': nbSkip,
      'current_streak': currentStreak,
      'best_streak': bestStreak,
      'last_reveal_date': lastRevealDate == null
          ? null
          : DateHelpers.toIsoDateString(lastRevealDate),
      'letters_mask': lettersMask,
      'gold_bookmark_mask': goldBookmarkMask,
      'emerald_since': emeraldSince == null
          ? null
          : DateHelpers.toIsoDateString(emeraldSince),
      'emerald_mask': emeraldMask,
      'emerald_bookmark_mask': emeraldBookmarkMask,
      'bookmark_fragments': bookmarkFragments,
      'bookmarks': bookmarks,
    };
  }
}
