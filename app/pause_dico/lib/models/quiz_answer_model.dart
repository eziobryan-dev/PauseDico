import 'reward_summary_model.dart';

/// Server's answer to a quiz question. On the last question it also carries
/// the score and the rewards (first completion of this quiz only).
class QuizAnswerModel {
  final int correctWordId;
  final bool isCorrect;
  final bool finished;
  final int? score;
  final int? total;
  final RewardSummaryModel? rewards;

  /// Weekly quiz of a past week: replayable, but gives no rewards
  final bool pastWeek;

  const QuizAnswerModel({
    required this.correctWordId,
    required this.isCorrect,
    required this.finished,
    this.score,
    this.total,
    this.rewards,
    this.pastWeek = false,
  });

  factory QuizAnswerModel.fromJson(Map<String, dynamic> json) {
    final rewards = json['rewards'] as Map<String, dynamic>?;
    return QuizAnswerModel(
      correctWordId: json['correct_word_id'] as int,
      isCorrect: json['is_correct'] as bool? ?? false,
      finished: json['finished'] as bool? ?? false,
      score: json['score'] as int?,
      total: json['total'] as int?,
      rewards: rewards == null ? null : RewardSummaryModel.fromJson(rewards),
      pastWeek: json['past_week'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'correct_word_id': correctWordId,
      'is_correct': isCorrect,
      'finished': finished,
      'score': score,
      'total': total,
      'rewards': rewards?.toJson(),
      'past_week': pastWeek,
    };
  }
}
