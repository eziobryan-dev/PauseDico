import 'package:flutter/material.dart';

import '../core/utils/date_helpers.dart';
import '../core/utils/text_helpers.dart';
import '../models/quiz_result_model.dart';
import '../models/special_quiz_model.dart';
import '../models/user_game_profile_model.dart';
import '../models/user_model.dart';
import '../models/user_word_history_model.dart';
import '../models/word_model.dart';
import '../services/level_service.dart';
import 'fake_backend.dart';
import 'fake_words.dart';

/// Builds a [FakeBackend] from a few figures: the history is generated day by
/// day (no word on Sundays, the weekly quiz day), the profile is derived from
/// it unless a figure is given explicitly.
abstract class FakeSeed {
  static const allLettersMask = (1 << 26) - 1;

  static FakeBackend backend({
    required DateTime today,
    int streakDays = 0,
    bool revealedToday = false,
    int olderWords = 0,
    List<String> historyWords = const [],
    List<String> poolFirst = const [],
    int likeEvery = 4,
    int? xp,
    int? nbWords,
    int fragments = 0,
    int bookmarks = 0,
    int? lettersMask,
    int goldBookmarkMask = 0,
    int? emeraldDaysAgo,
    List<SpecialQuizModel> pendingQuizzes = const [],
    Map<String, QuizResultModel> quizResults = const {},
    Map<FakeFailure, int> failures = const {},
    bool fragmentOnNextReveal = false,
  }) {
    today = DateHelpers.dateOnly(today);

    // Words: the explicit ones, then the dictionary order (pool words excluded)
    final reserved = {...poolFirst};
    final explicit = historyWords.map(FakeWords.named).toList();
    final generated = FakeWords.all
        .where((w) => !reserved.contains(w.name) && !historyWords.contains(w.name))
        .toList();
    final historySource = [...explicit, ...generated];
    final count = streakDays + olderWords;
    assert(count <= historySource.length, 'Pas assez de mots factices ($count)');

    // Dates: the streak (consecutive days, Sundays skipped), then a gap
    final dates = <DateTime>[];
    var cursor = revealedToday ? today : DateHelpers.addDays(today, -1);
    for (var i = 0; i < count; i++) {
      // Older words: one weekday without word first (a Sunday breaks nothing)
      if (i == streakDays) cursor = DateHelpers.addDays(_notSunday(cursor), -1);
      cursor = _notSunday(cursor);
      dates.add(cursor);
      cursor = DateHelpers.addDays(cursor, -1);
    }

    final history = [
      for (var i = 0; i < count; i++)
        UserWordHistoryModel(
          word: historySource[i],
          date: dates[i],
          liked: likeEvery > 0 && i % likeEvery == likeEvery - 1,
        ),
    ];
    final used = history.map((entry) => entry.word.id).toSet();
    final pool = [
      ...poolFirst.map(FakeWords.named),
      ...FakeWords.all.where((w) => !used.contains(w.id) && !reserved.contains(w.name)),
    ];

    final emeraldSince =
        emeraldDaysAgo == null ? null : DateHelpers.addDays(today, -emeraldDaysAgo);
    final totalXp = xp ?? 12 * count + 40;
    final profile = UserGameProfileModel(
      userId: _userId,
      level: LevelService.levelForXp(totalXp),
      xp: totalXp,
      nbWords: nbWords ?? count,
      nbQuizWeeklyCompleted: quizResults.length,
      nbQuizMonthlyCompleted: 0,
      nbQuizYearlyCompleted: 0,
      currentStreak: streakDays,
      bestStreak: streakDays > olderWords ? streakDays : olderWords,
      lastRevealDate: dates.firstOrNull,
      lettersMask: lettersMask ?? _mask(history.map((e) => e.word)),
      goldBookmarkMask: goldBookmarkMask,
      emeraldSince: emeraldSince,
      emeraldMask: emeraldSince == null
          ? 0
          : _mask(history.where((e) => e.date.isAfter(emeraldSince)).map((e) => e.word)),
      emeraldBookmarkMask: 0,
      bookmarkFragments: fragments,
      bookmarks: bookmarks,
    );

    final oldest = dates.isEmpty ? today : dates.last;
    return FakeBackend(
      user: UserModel(
        id: _userId,
        email: 'testeur@pausedico.test',
        username: 'Testeur',
        createdAt: DateHelpers.addDays(oldest, dates.isEmpty ? 0 : -2),
        notifTime: const TimeOfDay(hour: 9, minute: 0),
      ),
      profile: profile,
      history: history,
      pool: pool,
      pendingQuizzes: pendingQuizzes,
      quizResults: quizResults,
      failures: failures,
      fragmentOnNextReveal: fragmentOnNextReveal,
    );
  }

  static const _userId = 'fake-user';

  /// [date], or the Saturday before it if it is a Sunday
  static DateTime _notSunday(DateTime date) => date.weekday == DateTime.sunday
      ? DateHelpers.addDays(date, -1)
      : date;

  static int _mask(Iterable<WordModel> words) => words.fold(
        0,
        (mask, word) =>
            mask |
            UserGameProfileModel.letterBit(
              TextHelpers.normalize(word.name).substring(0, 1).toUpperCase(),
            ),
      );
}
