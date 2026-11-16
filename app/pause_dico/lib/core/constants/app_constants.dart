abstract class AppConstants {
  // App Metadata
  static const String appName = 'Pause Dico';
  static const String appLogoAsset = 'assets/icons/pause-dico.svg';
  static const String shareSignature =
      'Un nouveau mot chaque jour avec Pause Dico ✨';
  static const String wiktionaryIconAsset = 'assets/icons/wiktionary.png';

  // External Links
  static const String wiktionaryBaseUrl = 'https://fr.wiktionary.org/wiki/';

  // Supabase Credentials
  static const String supabaseUrl = 'https://dekiorcmhkijfuiibohz.supabase.co';
  static const String supabaseKey = 'sb_publishable_pFhKUjWhSQ3QGcS435XUtg_XWqS-46v';

  // Auth deep links (also declared in AndroidManifest.xml / Info.plist and
  // allowed in Supabase > Authentication > URL Configuration)
  static const String authRedirectUrl = 'io.supabase.pausedico://login-callback';
  static const String passwordResetRedirectUrl =
      'io.supabase.pausedico://reset-callback';

  // Database Tables
  static const String wordTable = 'word';
  static const String userTable = 'user';
  static const String userWordHistoryTable = 'user_word_history';
  static const String userGameProfileTable = 'user_game_profile';

  // Database Functions (RPC)
  static const String getDailyChoicesRpc = 'get_daily_choices';
  static const String revealDailyWordRpc = 'reveal_daily_word';
  static const String skipDailyWordRpc = 'skip_daily_word';
  static const String setWordLikedRpc = 'set_word_liked';
  static const String getPendingSpecialQuizzesRpc = 'get_pending_special_quizzes';
  static const String startQuizRpc = 'start_quiz';
  static const String answerQuizQuestionRpc = 'answer_quiz_question';
  static const String getQuizResultRpc = 'get_quiz_result';

  // Quiz
  static const Duration quizNextQuestionDelay = Duration(milliseconds: 1500);
  static const int quizMaxAnswerOptions = 10;
  /// Mirrors quiz_rules('weekly').min_words on the server
  static const int weeklyQuizMinWords = 3;

  // Daily Notification
  static const int dailyNotificationId = 0;
  static const String dailyNotificationChannelId = 'daily_word';
  static const String dailyNotificationChannelName = 'Mot du jour';
  static const String dailyNotificationBody = 'Découvre ton mot du jour !';
  static const String weeklyQuizNotificationBody =
      "C'est dimanche : ton Quiz hebdo t'attend !";
  /// Reminders scheduled ahead (one per day), refreshed at each app opening
  static const int scheduledRemindersCount = 14;
  static const int defaultNotifHour = 9;
  static const int defaultNotifMinute = 0;

  // Local Cache Keys (shared_preferences)
  static const String dailyNotificationEnabledKey = 'daily_notification_enabled';
  static const String darkThemeKey = 'dark_theme';
  static const String onboardingDoneKey = 'onboarding_done';

  // Ads
  /// Share of the home screen height taken by the ad, at the bottom
  static const double homeAdHeightRatio = 0.25;

  // Theme
  static const Duration darkThemeSaveDebounce = Duration(milliseconds: 600);
}