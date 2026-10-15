import 'quiz_question_model.dart';

/// A quiz started on the server: its questions, answered one by one.
/// An unfinished quiz is resumed where the user left it ([answered], [score]).
class QuizSessionModel {
  final String sessionId;
  final List<QuizQuestionModel> questions;

  /// Questions already answered (index of the next question to answer)
  final int answered;
  final int score;

  const QuizSessionModel({
    required this.sessionId,
    required this.questions,
    this.answered = 0,
    this.score = 0,
  });

  bool get isResumed => answered > 0;

  factory QuizSessionModel.fromJson(Map<String, dynamic> json) {
    return QuizSessionModel(
      sessionId: json['session_id'] as String,
      questions: ((json['questions'] as List?) ?? [])
          .map((question) =>
              QuizQuestionModel.fromJson(question as Map<String, dynamic>))
          .toList(),
      answered: json['answered'] as int? ?? 0,
      score: json['score'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'questions': questions.map((question) => question.toJson()).toList(),
      'answered': answered,
      'score': score,
    };
  }
}
