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
  static const String canClaimAdSkipRpc = 'can_claim_ad_skip';
  static const String claimAdSkipRpc = 'claim_ad_skip';
  static const String useBookmarkRpc = 'use_bookmark';

  // Bookmarks (mirror bookmark_rules() on the server)
  static const int fragmentsPerBookmark = 7;

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

  // Ads (Google AdMob). Google's test ids until the AdMob account exists:
  // replace them, and the app ids in AndroidManifest.xml / Info.plist,
  // before publishing (clicking real ads of your own app gets it banned)
  static const String admobBannerAndroid = 'ca-app-pub-3940256099942544/9214589741';
  static const String admobBannerIos = 'ca-app-pub-3940256099942544/2435281174';
  static const String admobRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const String admobRewardedIos = 'ca-app-pub-3940256099942544/1712485313';

  // Theme
  static const Duration darkThemeSaveDebounce = Duration(milliseconds: 600);
}