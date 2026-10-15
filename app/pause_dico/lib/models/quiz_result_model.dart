/// Rating of a finished quiz, from the share of good answers
enum QuizRating {
  perfect('Bravo !', 3),
  good('Pas mal.', 2),
  average('Mouais...', 1),
  zero('Nul nul nul...', 0);

  final String title;
  final int stars;

  const QuizRating(this.title, this.stars);
}

/// Score of a finished quiz
class QuizResultModel {
  final int score;
  final int total;

  const QuizResultModel({required this.score, required this.total});

  double get ratio => total == 0 ? 0 : score / total;

  QuizRating get rating {
    if (score == total) return QuizRating.perfect;
    if (score == 0) return QuizRating.zero;
    if (ratio >= 0.5) return QuizRating.good;
    return QuizRating.average;
  }

  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    return QuizResultModel(
      score: json['score'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'score': score, 'total': total};
}
