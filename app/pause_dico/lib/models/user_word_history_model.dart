import 'word_model.dart';

/// A word of the user's history, with the date it was learned and its like
class UserWordHistoryModel {
  final WordModel word;
  final DateTime date;
  final bool liked;

  const UserWordHistoryModel({
    required this.word,
    required this.date,
    this.liked = false,
  });

  factory UserWordHistoryModel.fromJson(Map<String, dynamic> json) {
    return UserWordHistoryModel(
      word: WordModel.fromJson(json['word'] as Map<String, dynamic>),
      date: DateTime.parse(json['date'] as String),
      liked: json['liked'] as bool? ?? false,
    );
  }

  UserWordHistoryModel copyWith({bool? liked}) {
    return UserWordHistoryModel(
      word: word,
      date: date,
      liked: liked ?? this.liked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word.toJson(),
      'date': date.toIso8601String().substring(0, 10),
      'liked': liked,
    };
  }
}
