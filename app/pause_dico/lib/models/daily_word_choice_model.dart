/// One of the 3 daily word candidates: only its theme is shown before choosing
class DailyWordChoiceModel {
  final int wordId;
  final String theme;

  const DailyWordChoiceModel({required this.wordId, required this.theme});

  factory DailyWordChoiceModel.fromJson(Map<String, dynamic> json) {
    return DailyWordChoiceModel(
      wordId: json['id'] as int,
      theme: json['theme'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': wordId, 'theme': theme};
}
