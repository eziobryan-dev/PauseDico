class WordModel {
  final int id;
  final String name;
  final String gender;
  final String type;
  final String theme;
  final String definition;

  const WordModel({
    required this.id,
    required this.name,
    required this.gender,
    this.type = '',
    this.theme = '',
    required this.definition,
  });

  /// Factory constructor to create a WordModel from Supabase JSON response
  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      type: json['type'] as String? ?? '',
      theme: json['theme'] as String? ?? '',
      definition: json['definition'] as String? ?? '',
    );
  }

  /// Converts a WordModel instance back to a Map/JSON structure
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'type': type,
      'theme': theme,
      'definition': definition,
    };
  }
}
