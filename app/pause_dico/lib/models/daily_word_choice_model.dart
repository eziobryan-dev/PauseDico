/// One of the 3 daily word candidates, shown with its theme before choosing
/// (its definition stays hidden until it is chosen)
class DailyWordChoiceModel {
  final int wordId;
  final String name;
  final String theme;

  const DailyWordChoiceModel({
    required this.wordId,
    required this.name,
    required this.theme,
  });

  factory DailyWordChoiceModel.fromJson(Map<String, dynamic> json) {
    return DailyWordChoiceModel(
      wordId: json['id'] as int,
      name: json['name'] as String? ?? '',
      theme: json['theme'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': wordId, 'name': name, 'theme': theme};
}
