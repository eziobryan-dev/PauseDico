/// An answer tag of a quiz question
class QuizOptionModel {
  final int wordId;
  final String name;

  const QuizOptionModel({required this.wordId, required this.name});

  factory QuizOptionModel.fromJson(Map<String, dynamic> json) {
    return QuizOptionModel(
      wordId: json['id'] as int,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': wordId, 'name': name};
}
