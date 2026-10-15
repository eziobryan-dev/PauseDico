import '../core/utils/date_helpers.dart';

class UserGameProfileModel {
  final String userId;
  final int level;
  final int xp;
  final int nbWords;
  final int nbQuizWeeklyCompleted;
  final int nbQuizMonthlyCompleted;
  final int nbQuizYearlyCompleted;
  final int nbSkip;
  final int currentStreak;
  final int bestStreak;
  final DateTime? lastRevealDate;

  /// One bit per discovered first letter: bit 0 = A … bit 25 = Z
  final int lettersMask;
  final bool hasAllLetters;

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
    required this.hasAllLetters,
  });

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

  bool hasLetter(String letter) =>
      lettersMask & (1 << (letter.codeUnitAt(0) - 'A'.codeUnitAt(0))) != 0;

  int get lettersCount => List.generate(26, (i) => lettersMask >> i & 1)
      .fold(0, (sum, bit) => sum + bit);

  factory UserGameProfileModel.fromJson(Map<String, dynamic> json) {
    final lastRevealDate = json['last_reveal_date'] as String?;
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
      hasAllLetters: json['has_all_letters'] as bool? ?? false,
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
      'has_all_letters': hasAllLetters,
    };
  }
}
