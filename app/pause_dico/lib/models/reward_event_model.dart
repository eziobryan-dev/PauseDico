/// One reward granted by the server (e.g. "Série de 7 jours !" +30 xp +1 skip)
class RewardEventModel {
  final String label;
  final int xp;

  /// Skips granted, including +1 per level gained
  final int skips;
  final bool levelUp;
  final int level;

  /// The discovered letter, for a "new letter" reward
  final String? letter;

  const RewardEventModel({
    required this.label,
    required this.xp,
    required this.skips,
    required this.levelUp,
    required this.level,
    this.letter,
  });

  factory RewardEventModel.fromJson(Map<String, dynamic> json) {
    return RewardEventModel(
      label: json['label'] as String? ?? '',
      xp: json['xp'] as int? ?? 0,
      skips: json['skips'] as int? ?? 0,
      levelUp: json['level_up'] as bool? ?? false,
      level: json['level'] as int? ?? 1,
      letter: json['letter'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'xp': xp,
      'skips': skips,
      'level_up': levelUp,
      'level': level,
      'letter': letter,
    };
  }
}
