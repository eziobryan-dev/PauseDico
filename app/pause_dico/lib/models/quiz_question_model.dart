import 'quiz_option_model.dart';

/// A quiz question: a definition and the words to choose from.
/// The right answer stays on the server.
class QuizQuestionModel {
  final String definition;
  /// Theme of the word to find, shown as a hint
  final String theme;
  final List<QuizOptionModel> options;

  const QuizQuestionModel({
    required this.definition,
    required this.theme,
    required this.options,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      definition: json['definition'] as String? ?? '',
      theme: json['theme'] as String? ?? '',
      options: ((json['options'] as List?) ?? [])
          .map((option) => QuizOptionModel.fromJson(option as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'definition': definition,
      'theme': theme,
      'options': options.map((option) => option.toJson()).toList(),
    };
  }
}
