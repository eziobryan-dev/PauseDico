import 'auth_repository.dart';
import 'quiz_repository.dart';
import 'user_game_profile_repository.dart';
import 'user_repository.dart';
import 'user_word_history_repository.dart';

/// Where screens and services get their repositories. Supabase by default;
/// debug scenarios and tests swap in in-memory fakes with [override].
/// Each call builds a new instance (each screen keeps its own caches), so
/// these are factories, not singletons.
abstract class Repositories {
  static AuthRepository Function() auth = AuthRepository.new;
  static UserRepository Function() user = UserRepository.new;
  static UserGameProfileRepository Function() gameProfile =
      UserGameProfileRepository.new;
  static UserWordHistoryRepository Function() history =
      UserWordHistoryRepository.new;
  static QuizRepository Function() quiz = QuizRepository.new;

  static void override({
    required AuthRepository Function() auth,
    required UserRepository Function() user,
    required UserGameProfileRepository Function() gameProfile,
    required UserWordHistoryRepository Function() history,
    required QuizRepository Function() quiz,
  }) {
    Repositories.auth = auth;
    Repositories.user = user;
    Repositories.gameProfile = gameProfile;
    Repositories.history = history;
    Repositories.quiz = quiz;
  }

  /// Back to Supabase
  static void reset() => override(
        auth: AuthRepository.new,
        user: UserRepository.new,
        gameProfile: UserGameProfileRepository.new,
        history: UserWordHistoryRepository.new,
        quiz: QuizRepository.new,
      );
}
