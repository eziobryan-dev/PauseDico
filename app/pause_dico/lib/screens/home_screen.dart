import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/app_clock.dart';
import '../core/utils/context_extensions.dart';
import '../core/utils/date_helpers.dart';
import '../models/quiz_result_model.dart';
import '../models/reward_summary_model.dart';
import '../models/special_quiz_model.dart';
import '../models/user_word_history_model.dart';
import '../models/word_model.dart';
import '../repositories/quiz_repository.dart';
import '../repositories/repositories.dart';
import '../repositories/user_game_profile_repository.dart';
import '../repositories/user_repository.dart';
import '../repositories/user_word_history_repository.dart';
import '../services/ad_service.dart';
import '../services/notification_service.dart';
import '../services/theme_service.dart';
import '../widgets/ad_slot.dart';
import '../widgets/app_logo.dart';
import '../widgets/date_navigator.dart';
import '../widgets/empty_word_card.dart';
import '../widgets/feature_card.dart';
import '../widgets/glowing_quiz_button.dart';
import '../widgets/quiz_done_card.dart';
import '../widgets/screen_title.dart';
import '../widgets/word_card.dart';
import '../widgets/theme_choice_overlay.dart';
import '../widgets/word_reveal_overlay.dart';
import 'alphabet_screen.dart';
import 'notebook_screen.dart';
import 'quiz_screen.dart';
import 'user_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final UserRepository _userRepository = Repositories.user();
  final UserWordHistoryRepository _historyRepository = Repositories.history();
  final QuizRepository _quizRepository = Repositories.quiz();
  final UserGameProfileRepository _gameProfileRepository =
      Repositories.gameProfile();

  DateTime _selectedDate = AppClock.today();
  DateTime? _userCreatedAt;
  TimeOfDay? _notifTime;
  DateTime _lastLoadedAt = AppClock.now();
  UserWordHistoryModel? _dailyEntry;
  List<WordModel> _weeklyWords = [];
  /// Result of the selected Sunday's weekly quiz, null until completed
  QuizResultModel? _weeklyResult;
  List<SpecialQuizModel> _pendingQuizzes = [];
  bool _isLoading = true;
  bool _isRevealing = false;
  String? _errorMessage;

  bool get _isSunday => _selectedDate.weekday == DateTime.sunday;

  bool get _isToday => _selectedDate == AppClock.today();

  bool get _canGoPrevious =>
      _userCreatedAt == null ||
      _selectedDate.isAfter(DateHelpers.dateOnly(_userCreatedAt!));

  bool get _canGoNext => _selectedDate.isBefore(AppClock.today());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchUserAndLoadWord();
    // Consent form (first launch in Europe), then ads
    AdService.init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Back to the app after midnight or after the reminder time since the
  /// last load: today's word is not loaded yet, so reload on today
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (!DateHelpers.hasCrossedDailyBoundary(
      _lastLoadedAt,
      AppClock.now(),
      _notifTime,
    )) {
      return;
    }

    setState(() => _selectedDate = AppClock.today());
    _fetchUserAndLoadWord(forceRefresh: true);
  }

  Future<void> _fetchUserAndLoadWord({bool forceRefresh = false}) async {
    _lastLoadedAt = AppClock.now();
    final userProfile = await _userRepository.getUser();
    if (mounted && userProfile != null) {
      setState(() {
        _userCreatedAt = userProfile.createdAt;
        _notifTime = userProfile.notifTime;
      });
      ThemeService.applyUserPreference(userProfile.darkTheme);
    }
    _loadPendingQuizzes();
    await _loadWordForDate(_selectedDate, forceRefresh: forceRefresh);
    _syncReminders();
  }

  /// Keeps the reminders in sync: none today once the word is revealed, and
  /// the current streak in the next one
  Future<void> _syncReminders() async {
    try {
      if (!await NotificationService.isEnabled()) return;
      final today = AppClock.today();
      final todayEntry = await _historyRepository.getWordByDate(today);
      final profile = await _gameProfileRepository.getProfile();
      await NotificationService.scheduleReminders(
        _notifTime ?? NotificationService.defaultTime,
        revealedToday: todayEntry != null,
        streak: profile?.activeStreak(today) ?? 0,
      );
    } catch (e) {
      // Not blocking: the previous reminders stay scheduled
    }
  }

  /// Monthly / yearly quizzes waiting to be played (they stay until completed)
  Future<void> _loadPendingQuizzes() async {
    try {
      final quizzes = await _quizRepository.getPendingQuizzes(AppClock.today());
      if (mounted) setState(() => _pendingQuizzes = quizzes);
    } catch (e) {
      // Not blocking: the icon will show up on the next load
    }
  }

  /// Loads the word of [date], from the repository cache unless [forceRefresh]
  Future<void> _loadWordForDate(DateTime date, {bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final entry = await _historyRepository.getWordByDate(
        date,
        forceRefresh: forceRefresh,
      );
      final isSunday = date.weekday == DateTime.sunday;
      final weeklyWords = isSunday
          ? await _historyRepository.getWeekWords(
              date,
              forceRefresh: forceRefresh,
            )
          : <WordModel>[];
      final weeklyResult = isSunday
          ? await _quizRepository.getResult(QuizKind.weekly, date)
          : null;

      if (!mounted) return;
      setState(() {
        _dailyEntry = entry;
        _weeklyWords = weeklyWords;
        _weeklyResult = weeklyResult;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Impossible de charger le mot du jour.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _revealDailyWord() async {
    final date = _selectedDate;
    setState(() => _isRevealing = true);

    try {
      // 1. The user picks one of the 3 candidate themes (the overlay opens
      //    right away and shows a spinner while they load)
      final reveal = await ThemeChoiceOverlay.show(
        context,
        loadChoices: () => _historyRepository.getDailyChoices(date),
        onPick: (wordId) => _historyRepository.revealDailyWord(date, wordId),
      );
      if (!mounted || reveal == null) return;
      // Revealed: no reminder today, and the new streak in the next one
      _syncReminders();

      // 2. Its word is revealed with the entrance animation
      final kept = await WordRevealOverlay.show(
        context,
        reveal: reveal,
        onSkip: () => _historyRepository.skipDailyWord(date),
        onLikeChanged: _historyRepository.setWordLiked,
        canWatchAdForSkip: () async =>
            AdService.isReady.value &&
            await _gameProfileRepository.canClaimAdSkip(date),
        onWatchAdForSkip: () => _watchAdForSkip(date),
      );
      if (!mounted) return;

      if (kept == null) {
        // Overlay closed without "OK !" (back button): reload the saved word
        await _fetchUserAndLoadWord();
      } else {
        setState(() {
          _dailyEntry = UserWordHistoryModel(
            word: kept.word,
            date: date,
            liked: kept.liked,
          );
        });
      }
    } catch (e) {
      if (mounted) context.showSnackBar('Impossible de révéler le mot du jour.');
    } finally {
      if (mounted) setState(() => _isRevealing = false);
    }
  }

  /// Rewarded ad, then the server grants the skip (null if not watched)
  Future<RewardSummaryModel?> _watchAdForSkip(DateTime date) async {
    if (!await AdService.showRewardedAd()) return null;
    return _gameProfileRepository.claimAdSkip(date);
  }

  Future<bool> _setDailyWordLiked(bool liked) async {
    final entry = _dailyEntry!;
    final saved = await _historyRepository.setWordLiked(entry.word.id, liked);
    // Ignore the result if the displayed word changed meanwhile
    if (mounted && _dailyEntry?.word.id == entry.word.id) {
      setState(() => _dailyEntry = _dailyEntry!.copyWith(liked: saved));
    }
    return saved;
  }

  /// Calendar arithmetic (not +24h): safe across daylight saving changes
  void _changeDate(int daysOffset) => _goToDate(DateHelpers.addDays(_selectedDate, daysOffset));

  void _goToDate(DateTime date) {
    setState(() => _selectedDate = date);
    _loadWordForDate(date);
  }

  Future<void> _openProfile() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const UserScreen()),
    );
    // Refresh user profile info on return
    _fetchUserAndLoadWord();
  }

  Future<void> _openWeeklyQuiz() async {
    final date = _selectedDate;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizScreen(kind: QuizKind.weekly, refDate: date),
      ),
    );
    // Completed: the card now shows the result
    final result = await _quizRepository.getResult(QuizKind.weekly, date);
    if (mounted && _selectedDate == date) setState(() => _weeklyResult = result);
  }

  Future<void> _openSpecialQuiz(SpecialQuizModel quiz) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizScreen(kind: quiz.kind, refDate: quiz.dueDate),
      ),
    );
    // A completed quiz is no longer pending: its icon goes away
    _loadPendingQuizzes();
  }

  Future<void> _openNotebook() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const NotebookScreen()),
    );
    // Likes may have changed in the notebook
    _loadWordForDate(_selectedDate, forceRefresh: true);
  }

  void _openAlphabet() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AlphabetScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Brand title on the left (the theme centers the other screens' titles)
        centerTitle: false,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(size: 32),
            SizedBox(width: 10),
            Flexible(child: ScreenTitle('PauseDico')),
          ],
        ),
        actions: [
          for (final quiz in _pendingQuizzes)
            GlowingQuizButton(
              kind: quiz.kind,
              onPressed: () => _openSpecialQuiz(quiz),
            ),
          IconButton(
            icon: const Icon(Icons.menu_book_rounded),
            tooltip: 'Mon carnet',
            onPressed: _openNotebook,
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events_rounded),
            tooltip: 'Alphadex',
            onPressed: _openAlphabet,
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profil',
            onPressed: _openProfile,
          ),
        ],
      ),
      // Banner anchored at the bottom, the content scrolls above
      body: Column(
        children: [
          Expanded(child: _buildScrollableContent()),
          const AdSlot(),
        ],
      ),
    );
  }

  Widget _buildScrollableContent() {
    return RefreshIndicator(
      onRefresh: () {
        _loadPendingQuizzes();
        return _loadWordForDate(_selectedDate, forceRefresh: true);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DateNavigator(
              date: _selectedDate,
              firstDate: _userCreatedAt ?? _selectedDate,
              canGoPrevious: _canGoPrevious,
              canGoNext: _canGoNext,
              onChangeDay: _changeDate,
              onPickDate: _goToDate,
            ),
            const SizedBox(height: 24),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(48.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return FeatureCard(
        tone: FeatureCardTone.error,
        icon: Icons.error_outline,
        message: _errorMessage!,
        actionLabel: 'Réessayer',
        actionIcon: Icons.refresh,
        onAction: () => _loadWordForDate(_selectedDate, forceRefresh: true),
      );
    }

    if (_isSunday) {
      if (_weeklyResult case final result?) {
        return QuizDoneCard(title: QuizKind.weekly.title, result: result);
      }
      final canPlay = _weeklyWords.length >= AppConstants.weeklyQuizMinWords;
      return FeatureCard(
        icon: Icons.star,
        title: QuizKind.weekly.title,
        message: canPlay
            ? 'Testez vos connaissances de la semaine avec le quiz récapitulatif !'
            : 'Il faut au moins ${AppConstants.weeklyQuizMinWords} mots dans la '
                'semaine pour jouer (${_weeklyWords.length} cette fois-ci).',
        actionLabel: 'Commencer le quiz',
        actionIcon: Icons.quiz,
        onAction: canPlay ? _openWeeklyQuiz : null,
      );
    }

    final entry = _dailyEntry;
    if (entry != null) {
      return WordCard(
        // New key per word so the heart state never leaks between days
        key: ValueKey(entry.word.id),
        word: entry.word,
        liked: entry.liked,
        onLikeChanged: _setDailyWordLiked,
      );
    }

    if (!_isToday) return const EmptyWordCard();

    return FeatureCard(
      icon: Icons.auto_awesome,
      title: 'Mot du jour',
      message: 'Un nouveau mot vous attend !',
      actionLabel: 'Révéler le mot du jour',
      actionIcon: Icons.visibility,
      onAction: _isRevealing ? null : _revealDailyWord,
    );
  }
}
