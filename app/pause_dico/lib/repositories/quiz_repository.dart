import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/date_helpers.dart';
import '../models/quiz_answer_model.dart';
import '../models/quiz_session_model.dart';
import '../models/special_quiz_model.dart';

/// Quizzes are played on the server: it keeps the answers, scores the quiz and
/// grants the rewards (first completion only). Monthly / yearly quizzes stay
/// pending until completed, even if the user did not open the app that day.
class QuizRepository {
  final SupabaseClient _client;

  QuizRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Pending (eligible and not completed) special quizzes as of [today]
  Future<List<SpecialQuizModel>> getPendingQuizzes(DateTime today) async {
    if (_client.auth.currentUser == null) return [];

    final response = await _client.rpc(
      AppConstants.getPendingSpecialQuizzesRpc,
      params: {'p_date': DateHelpers.toIsoDateString(today)},
    );
    return (response as List)
        .map((json) => SpecialQuizModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Starts a quiz: [refDate] is the Sunday of a weekly quiz, or the due date
  /// of a special quiz
  Future<QuizSessionModel> startQuiz(
    QuizKind kind,
    DateTime refDate,
    DateTime today,
  ) async {
    final response = await _client.rpc(
      AppConstants.startQuizRpc,
      params: {
        'p_date': DateHelpers.toIsoDateString(today),
        'p_kind': kind.dbValue,
        'p_ref_date': DateHelpers.toIsoDateString(refDate),
      },
    );
    return QuizSessionModel.fromJson(response as Map<String, dynamic>);
  }

  /// Answers question [index] (0-based, in order) with [wordId]
  Future<QuizAnswerModel> answer(String sessionId, int index, int wordId) async {
    final response = await _client.rpc(
      AppConstants.answerQuizQuestionRpc,
      params: {
        'p_session_id': sessionId,
        'p_index': index,
        'p_word_id': wordId,
      },
    );
    return QuizAnswerModel.fromJson(response as Map<String, dynamic>);
  }
}
