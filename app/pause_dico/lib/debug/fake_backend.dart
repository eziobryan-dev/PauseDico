import 'dart:math';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthResponse, User;

import '../core/constants/app_constants.dart';
import '../core/utils/app_clock.dart';
import '../core/utils/date_helpers.dart';
import '../core/utils/text_helpers.dart';
import '../models/alphabet_tier_model.dart';
import '../models/daily_word_choice_model.dart';
import '../models/daily_word_reveal_model.dart';
import '../models/quiz_answer_model.dart';
import '../models/quiz_option_model.dart';
import '../models/quiz_question_model.dart';
import '../models/quiz_result_model.dart';
import '../models/quiz_session_model.dart';
import '../models/reward_event_model.dart';
import '../models/reward_summary_model.dart';
import '../models/special_quiz_model.dart';
import '../models/user_game_profile_model.dart';
import '../models/user_model.dart';
import '../models/user_word_history_model.dart';
import '../models/word_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/quiz_repository.dart';
import '../repositories/user_game_profile_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/user_word_history_repository.dart';
import '../services/level_service.dart';

/// A call that a scenario makes fail (simulated network / server error)
enum FakeFailure { loadWord, dailyChoices, reveal, like, profile, quizStart, quizAnswer }

class FakeBackendException implements Exception {
  final String message;

  const FakeBackendException(this.message);

  @override
  String toString() => 'FakeBackendException: $message';
}

/// In-memory stand-in for Supabase, used by the debug scenarios and the
/// widget tests: it implements every repository, so screens run unchanged
/// without network nor database.
///
/// It replays the server rules described in CLAUDE.md (reveal, streak,
/// letters, bookmarks, quiz rewards) closely enough to test the UI. The SQL
/// RPCs stay the source of truth: when a rule changes there, update
/// [_Rules] and the logic below.
class FakeBackend
    implements
        AuthRepository,
        UserRepository,
        UserGameProfileRepository,
        UserWordHistoryRepository,
        QuizRepository {
  FakeBackend({
    required this._user,
    required UserGameProfileModel profile,
    List<UserWordHistoryModel> history = const [],
    List<WordModel> pool = const [],
    List<SpecialQuizModel> pendingQuizzes = const [],
    Map<String, QuizResultModel> quizResults = const {},
    Map<FakeFailure, int> failures = const {},
    this.fragmentOnNextReveal = false,
    this.latency = const Duration(milliseconds: 300),
  })  : _profile = profile,
        _history = [...history],
        _pool = [...pool],
        _pendingQuizzes = [...pendingQuizzes],
        _quizResults = {...quizResults},
        _failures = {...failures} {
    for (final word in [...pool, ...history.map((entry) => entry.word)]) {
      _words[word.id] = word;
    }
    for (var i = 0; i < 26; i++) {
      final letter = String.fromCharCode(65 + i);
      final bit = 1 << i;
      if ((profile.lettersMask | profile.goldBookmarkMask) & bit != 0) {
        _rewardedLetters.add('${AlphabetTier.gold.dbValue}:$letter');
      }
      if ((profile.emeraldMask | profile.emeraldBookmarkMask) & bit != 0) {
        _rewardedLetters.add('${AlphabetTier.emerald.dbValue}:$letter');
      }
    }
  }

  /// Simulated network delay of every call (zero in widget tests)
  Duration latency;

  /// The next reveal finds a bookmark fragment (5 % chance on the server)
  bool fragmentOnNextReveal;

  /// Sign out / account deletion (no real session to end)
  VoidCallback? onSignedOut;

  UserModel _user;
  UserGameProfileModel _profile;
  final List<UserWordHistoryModel> _history;

  /// Words never had by the user, in draw order (daily candidates)
  final List<WordModel> _pool;
  final List<SpecialQuizModel> _pendingQuizzes;
  final Map<String, QuizResultModel> _quizResults;

  /// Calls left to fail per kind (-1: always)
  final Map<FakeFailure, int> _failures;

  final Map<int, WordModel> _words = {};
  final Map<String, List<int>> _dailyChoices = {};
  final Map<String, _FakeQuizSession> _quizSessions = {};
  final Set<String> _rewardedLetters = {};
  int _sessionCounter = 0;

  /// Current profile, for tests checking what an action changed
  UserGameProfileModel get profile => _profile;

  static String quizKey(QuizKind kind, DateTime refDate) =>
      '${kind.dbValue}|${DateHelpers.toIsoDateString(refDate)}';

  Future<T> _respond<T>(T Function() action, [FakeFailure? failure]) async {
    await Future<void>.delayed(latency);
    if (failure != null) {
      final left = _failures[failure] ?? 0;
      if (left != 0) {
        if (left > 0) _failures[failure] = left - 1;
        throw FakeBackendException('Échec simulé : ${failure.name}');
      }
    }
    return action();
  }

  Future<T> _unsupported<T>() =>
      Future.error(UnsupportedError("Pas d'authentification en mode scénario"));

  // ---------------------------------------------------------------- Auth

  @override
  User? get currentUser => null;

  @override
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) =>
      _unsupported();

  @override
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _unsupported();

  @override
  Future<bool> signInWithGoogle() => _unsupported();

  @override
  Future<void> sendPasswordReset(String email) => _unsupported();

  @override
  Future<void> updatePassword(String password) => _unsupported();

  @override
  Future<void> signOut() => _respond(() => onSignedOut?.call());

  @override
  Future<void> deleteAccount() => _respond(() => onSignedOut?.call());

  // ---------------------------------------------------------------- User

  @override
  Future<UserModel?> getUser() => _respond(() => _user);

  @override
  Future<void> patchDarkTheme(bool darkTheme) =>
      _respond(() => _user = _user.copyWith(darkTheme: darkTheme));

  @override
  Future<void> patchNotifTime(String userId, TimeOfDay time) =>
      _respond(() => _user = _user.copyWith(notifTime: time));

  @override
  Future<void> patchUsername(String userId, String newUsername) =>
      _respond(() => _user = _user.copyWith(username: newUsername));

  // ---------------------------------------------------------- Game profile

  @override
  Future<UserGameProfileModel?> getProfile() =>
      _respond(() => _profile, FakeFailure.profile);

  @override
  Future<RewardSummaryModel> useBookmark(DateTime today, String letter) =>
      _respond(() {
        if (_profile.bookmarks <= 0) throw const FakeBackendException('Aucun marque-page');
        if (_profile.hasLetter(letter)) {
          throw FakeBackendException('Lettre $letter déjà débloquée');
        }
        _profile = _profile.copyWith(bookmarks: _profile.bookmarks - 1);
        return _grant(_unlockLetter(letter, today, viaBookmark: true));
      });

  // ------------------------------------------------------------- History

  @override
  Future<List<UserWordHistoryModel>> getAllWords() => _respond(
        () => [..._history]..sort((a, b) => b.date.compareTo(a.date)),
        FakeFailure.loadWord,
      );

  @override
  Future<UserWordHistoryModel?> getWordByDate(
    DateTime date, {
    bool forceRefresh = false,
  }) =>
      _respond(() => _entryAt(date), FakeFailure.loadWord);

  @override
  Future<List<WordModel>> getWordsByLetter(String letter) => _respond(
        () => [
          for (final entry in _history)
            if (_firstLetter(entry.word.name) == letter) entry.word,
        ]..sort((a, b) => a.name.compareTo(b.name)),
      );

  @override
  Future<List<WordModel>> getWeekWords(
    DateTime sunday, {
    bool forceRefresh = false,
  }) =>
      _respond(() => _weekEntries(sunday).map((entry) => entry.word).toList());

  @override
  Future<List<DailyWordChoiceModel>> getDailyChoices(DateTime date) => _respond(
        () => [
          for (final id in _choicesFor(date))
            DailyWordChoiceModel(
              wordId: id,
              name: _words[id]!.name,
              theme: _words[id]!.theme,
            ),
        ],
        FakeFailure.dailyChoices,
      );

  @override
  Future<DailyWordRevealModel> revealDailyWord(DateTime date, int wordId) =>
      _respond(() => _reveal(date, wordId), FakeFailure.reveal);

  @override
  Future<bool> setWordLiked(int wordId, bool liked) => _respond(() {
        final index = _history.indexWhere((entry) => entry.word.id == wordId);
        if (index == -1) throw FakeBackendException('Mot $wordId absent de l\'historique');
        _history[index] = _history[index].copyWith(liked: liked);
        return liked;
      }, FakeFailure.like);

  @override
  Future<bool> isWordAcknowledged(int wordId) =>
      _respond(() => _history.any((entry) => entry.word.id == wordId));

  // ---------------------------------------------------------------- Quiz

  @override
  Future<List<SpecialQuizModel>> getPendingQuizzes(DateTime today) =>
      _respond(() => [..._pendingQuizzes]);

  @override
  Future<QuizSessionModel> startQuiz(QuizKind kind, DateTime refDate, DateTime today) =>
      _respond(() => _startQuiz(kind, refDate).toModel(), FakeFailure.quizStart);

  @override
  Future<QuizResultModel?> getResult(QuizKind kind, DateTime refDate) =>
      _respond(() => _quizResults[quizKey(kind, refDate)]);

  @override
  Future<QuizAnswerModel> answer(String sessionId, int index, int wordId) =>
      _respond(() => _answer(sessionId, index, wordId), FakeFailure.quizAnswer);

  /// Starts [kind]'s quiz and answers its first [answered] questions, the
  /// first [correct] ones right: opening it again resumes there
  void seedQuizProgress(
    QuizKind kind,
    DateTime refDate, {
    required int answered,
    required int correct,
  }) {
    final session = _startQuiz(kind, refDate);
    for (var i = 0; i < answered; i++) {
      final word = session.words[i];
      final wrong = session.questions[i].options.firstWhere((o) => o.wordId != word.id);
      _answer(session.id, i, i < correct ? word.id : wrong.wordId);
    }
  }

  // --------------------------------------------------------------- Rules

  UserWordHistoryModel? _entryAt(DateTime date) {
    final day = DateHelpers.dateOnly(date);
    return _history.where((entry) => entry.date == day).firstOrNull;
  }

  List<UserWordHistoryModel> _weekEntries(DateTime sunday) {
    final start = DateHelpers.weekStart(sunday);
    final end = DateHelpers.weekEnd(sunday);
    return _history
        .where((entry) => !entry.date.isBefore(start) && !entry.date.isAfter(end))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  static String _firstLetter(String name) =>
      TextHelpers.normalize(name).substring(0, 1).toUpperCase();

  /// 3 candidates with different themes, drawn once per day (pool order)
  List<int> _choicesFor(DateTime date) {
    return _dailyChoices.putIfAbsent(DateHelpers.toIsoDateString(date), () {
      final themes = <String>{};
      return [
        for (final word in _pool)
          if (themes.add(word.theme)) word.id,
      ].take(3).toList();
    });
  }

  DailyWordRevealModel _reveal(DateTime date, int wordId) {
    final existing = _entryAt(date);
    if (existing != null) {
      // Idempotent: already revealed, no new reward
      return DailyWordRevealModel(word: existing.word, liked: existing.liked);
    }
    final choices = _dailyChoices[DateHelpers.toIsoDateString(date)];
    if (choices == null || !choices.contains(wordId)) {
      throw FakeBackendException('Mot $wordId hors des choix du jour');
    }

    final word = _words[wordId]!;
    _pool.removeWhere((w) => w.id == wordId);
    _history.add(UserWordHistoryModel(word: word, date: DateHelpers.dateOnly(date)));

    final streak = _profile.activeStreak(date) + 1;
    final nbWords = _profile.nbWords + 1;
    _profile = _profile.copyWith(
      nbWords: nbWords,
      currentStreak: streak,
      bestStreak: max(streak, _profile.bestStreak),
      lastRevealDate: DateHelpers.dateOnly(date),
    );

    final events = [
      _event('reveal', 'Mot du jour révélé', xp: _Rules.revealXp),
      ..._streakEvents(streak),
      ..._unlockLetter(_firstLetter(word.name), date),
      if (nbWords % _Rules.wordsMilestone == 0)
        _event(
          'words_milestone',
          '$nbWords mots débloqués !',
          xp: _Rules.wordsMilestoneXp,
          fragments: 1,
          words: nbWords,
        ),
      if (fragmentOnNextReveal)
        _event('fragment', 'Fragment de marque-page trouvé', fragments: 1),
    ];
    fragmentOnNextReveal = false;

    return DailyWordRevealModel(word: word, rewards: _grant(events));
  }

  List<RewardEventModel> _streakEvents(int streak) {
    final xp = streak % 100 == 0
        ? 300
        : switch (streak) {
            30 => 100,
            7 => 30,
            3 => 15,
            _ => 0,
          };
    if (xp == 0) return [];
    return [_event('streak', 'Série de $streak jours !', xp: xp)];
  }

  /// Unlocks [letter] in the current tier; rewarded only the first time
  List<RewardEventModel> _unlockLetter(
    String letter,
    DateTime date, {
    bool viaBookmark = false,
  }) {
    final p = _profile;
    if (p.hasLetter(letter)) return [];

    final bit = UserGameProfileModel.letterBit(letter);
    final isGold = p.tier == AlphabetTier.gold;
    _profile = switch ((isGold, viaBookmark)) {
      (true, true) => p.copyWith(goldBookmarkMask: p.goldBookmarkMask | bit),
      (true, false) => p.copyWith(lettersMask: p.lettersMask | bit),
      (false, true) => p.copyWith(emeraldBookmarkMask: p.emeraldBookmarkMask | bit),
      (false, false) => p.copyWith(emeraldMask: p.emeraldMask | bit),
    };
    if (!_rewardedLetters.add('${p.tier.dbValue}:$letter')) return [];

    final events = [
      isGold
          ? _event('letter', 'Nouvelle lettre : $letter', xp: _Rules.goldLetterXp, letter: letter)
          : _event('emerald_letter', "Lettre d'émeraude : $letter",
              xp: _Rules.emeraldLetterXp, letter: letter),
    ];
    if (_profile.hasAllLetters) {
      if (isGold) {
        _profile = _profile.copyWith(emeraldSince: DateHelpers.dateOnly(date));
        events.add(_event('all_letters', 'Alphadex doré complet !',
            xp: _Rules.allGoldLettersXp, emeraldUnlocked: true));
      } else {
        events.add(_event('all_emerald_letters', "Alphadex d'émeraude complet !",
            xp: _Rules.allEmeraldLettersXp, emeraldCompleted: true));
      }
    }
    return events;
  }

  /// Applies [events] to the profile one by one (xp capped, 7 fragments =
  /// 1 bookmark), like `grant_reward`
  RewardSummaryModel _grant(List<RewardEventModel> events) {
    final granted = <RewardEventModel>[];
    for (final event in events) {
      final p = _profile;
      final xp = min(p.xp + event.xp, LevelService.xpForLevel(LevelService.maxLevel));
      final level = LevelService.levelForXp(xp);
      final fragments = p.bookmarkFragments + event.fragments;
      final assembled = fragments ~/ AppConstants.fragmentsPerBookmark;

      _profile = p.copyWith(
        xp: xp,
        level: level,
        bookmarkFragments: fragments % AppConstants.fragmentsPerBookmark,
        bookmarks: p.bookmarks + assembled,
      );
      granted.add(RewardEventModel(
        source: event.source,
        label: event.label,
        xp: xp - p.xp,
        fragments: event.fragments,
        bookmarks: assembled,
        tier: p.tier,
        levelUp: level > p.level,
        level: level,
        letter: event.letter,
        words: event.words,
        emeraldUnlocked: event.emeraldUnlocked,
        emeraldCompleted: event.emeraldCompleted,
      ));
    }

    final p = _profile;
    return RewardSummaryModel(
      events: granted,
      xp: p.xp,
      level: p.level,
      nbWords: p.nbWords,
      currentStreak: p.currentStreak,
      bookmarkFragments: p.bookmarkFragments,
      bookmarks: p.bookmarks,
      tier: p.tier,
    );
  }

  static RewardEventModel _event(
    String source,
    String label, {
    int xp = 0,
    int fragments = 0,
    String? letter,
    int? words,
    bool emeraldUnlocked = false,
    bool emeraldCompleted = false,
  }) {
    return RewardEventModel(
      source: source,
      label: label,
      xp: xp,
      fragments: fragments,
      bookmarks: 0,
      tier: AlphabetTier.gold,
      levelUp: false,
      level: 1,
      letter: letter,
      words: words,
      emeraldUnlocked: emeraldUnlocked,
      emeraldCompleted: emeraldCompleted,
    );
  }

  _FakeQuizSession _startQuiz(QuizKind kind, DateTime refDate) {
    final key = quizKey(kind, refDate);
    final existing = _quizSessions[key];
    if (existing != null && !existing.finished) return existing;

    final words = _quizWords(kind, refDate);
    if (words.isEmpty) throw const FakeBackendException('Pas assez de mots');

    final random = Random(key.hashCode);
    words.shuffle(random);
    final questions = [
      for (final word in words)
        QuizQuestionModel(
          definition: word.definition,
          theme: word.theme,
          options: [
            word,
            ...(words.where((w) => w.id != word.id).toList()..shuffle(random))
                .take(AppConstants.quizMaxAnswerOptions - 1),
          ]
              .map((w) => QuizOptionModel(wordId: w.id, name: w.name))
              .toList()
            ..shuffle(random),
        ),
    ];
    return _quizSessions[key] = _FakeQuizSession(
      id: 'fake-session-${++_sessionCounter}',
      kind: kind,
      refDate: refDate,
      words: words,
      questions: questions,
    );
  }

  /// Weekly: the week's words. Monthly / yearly: words of the period, liked first
  List<WordModel> _quizWords(QuizKind kind, DateTime refDate) {
    final count = _Rules.quizWords[kind]!;
    if (kind == QuizKind.weekly) {
      return _weekEntries(refDate).map((entry) => entry.word).take(count).toList();
    }
    final periodDays = kind == QuizKind.monthly ? 30 : 365;
    final start = DateHelpers.addDays(refDate, -periodDays);
    final entries = _history
        .where((entry) => entry.date.isAfter(start) && !entry.date.isAfter(refDate))
        .toList()
      ..sort((a, b) => a.liked == b.liked ? b.date.compareTo(a.date) : (a.liked ? -1 : 1));
    return entries.map((entry) => entry.word).take(count).toList();
  }

  QuizAnswerModel _answer(String sessionId, int index, int wordId) {
    final session = _quizSessions.values.where((s) => s.id == sessionId).firstOrNull;
    if (session == null) throw FakeBackendException('Session $sessionId inconnue');
    if (index != session.answered) {
      throw FakeBackendException('Question $index hors ordre (attendue ${session.answered})');
    }

    final correctWordId = session.words[index].id;
    final isCorrect = wordId == correctWordId;
    session.answered++;
    if (isCorrect) session.score++;
    if (!session.finished) {
      return QuizAnswerModel(
        correctWordId: correctWordId,
        isCorrect: isCorrect,
        finished: false,
      );
    }

    final key = quizKey(session.kind, session.refDate);
    final score = session.score;
    final total = session.words.length;
    final firstCompletion = !_quizResults.containsKey(key);
    final pastWeek = session.kind == QuizKind.weekly &&
        DateHelpers.daysBetween(session.refDate, AppClock.today()) >= 7;

    var events = <RewardEventModel>[];
    if (firstCompletion) {
      _quizResults[key] = QuizResultModel(score: score, total: total);
      _pendingQuizzes.removeWhere(
        (quiz) => quiz.kind == session.kind && quiz.dueDate == session.refDate,
      );
      _profile = switch (session.kind) {
        QuizKind.weekly => _profile.copyWith(
            nbQuizWeeklyCompleted: _profile.nbQuizWeeklyCompleted + 1),
        QuizKind.monthly => _profile.copyWith(
            nbQuizMonthlyCompleted: _profile.nbQuizMonthlyCompleted + 1),
        QuizKind.yearly => _profile.copyWith(
            nbQuizYearlyCompleted: _profile.nbQuizYearlyCompleted + 1),
      };
      if (!pastWeek) {
        final (perAnswer, perfectBonus) = _Rules.quizXp[session.kind]!;
        events = [
          if (score > 0)
            _event('quiz', '$score bonne${score > 1 ? 's' : ''} réponse${score > 1 ? 's' : ''}',
                xp: score * perAnswer),
          if (score == total) _event('quiz_perfect', 'Quiz parfait !', xp: perfectBonus),
        ];
      }
    }

    return QuizAnswerModel(
      correctWordId: correctWordId,
      isCorrect: isCorrect,
      finished: true,
      score: score,
      total: total,
      rewards: _grant(events),
      pastWeek: pastWeek,
    );
  }
}

/// A quiz being played on the fake server
class _FakeQuizSession {
  final String id;
  final QuizKind kind;
  final DateTime refDate;
  final List<WordModel> words;
  final List<QuizQuestionModel> questions;
  int answered = 0;
  int score = 0;

  _FakeQuizSession({
    required this.id,
    required this.kind,
    required this.refDate,
    required this.words,
    required this.questions,
  });

  bool get finished => answered >= words.length;

  QuizSessionModel toModel() => QuizSessionModel(
        sessionId: id,
        questions: questions,
        answered: answered,
        score: score,
      );
}

/// Mirror of the server rules (bookmark_rules, quiz_rules…)
abstract class _Rules {
  static const revealXp = 10;
  static const goldLetterXp = 20;
  static const emeraldLetterXp = 30;
  static const allGoldLettersXp = 500;
  static const allEmeraldLettersXp = 750;
  static const wordsMilestone = 50;
  static const wordsMilestoneXp = 100;

  static const quizWords = {QuizKind.weekly: 6, QuizKind.monthly: 15, QuizKind.yearly: 50};

  /// Xp per right answer, and bonus for a perfect quiz
  static const quizXp = {
    QuizKind.weekly: (5, 20),
    QuizKind.monthly: (7, 50),
    QuizKind.yearly: (10, 150),
  };
}
