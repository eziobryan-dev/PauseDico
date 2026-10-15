/// Kind of quiz, with its title and its database value
enum QuizKind {
  weekly('Quiz hebdo', 'weekly'),
  monthly('Quiz du mois', 'monthly'),
  yearly("Quiz de l'année", 'yearly');

  final String title;
  final String dbValue;

  const QuizKind(this.title, this.dbValue);

  static QuizKind fromDb(String value) =>
      QuizKind.values.firstWhere((kind) => kind.dbValue == value);
}

/// A monthly / yearly quiz waiting to be completed (its words come with the
/// quiz session)
class SpecialQuizModel {
  final QuizKind kind;
  final DateTime dueDate;

  const SpecialQuizModel({required this.kind, required this.dueDate});

  factory SpecialQuizModel.fromJson(Map<String, dynamic> json) {
    return SpecialQuizModel(
      kind: QuizKind.fromDb(json['kind'] as String),
      dueDate: DateTime.parse(json['due_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind.dbValue,
      'due_date': dueDate.toIso8601String().substring(0, 10),
    };
  }
}
