import 'reward_event_model.dart';

/// Rewards granted by an action (reveal, skip, quiz) and the resulting profile
class RewardSummaryModel {
  final List<RewardEventModel> events;
  final int xp;
  final int level;
  final int nbSkip;
  final int currentStreak;

  const RewardSummaryModel({
    required this.events,
    required this.xp,
    required this.level,
    required this.nbSkip,
    required this.currentStreak,
  });

  bool get isEmpty => events.isEmpty;

  int get totalXp => events.fold(0, (sum, event) => sum + event.xp);

  int get totalSkips => events.fold(0, (sum, event) => sum + event.skips);

  bool get hasLevelUp => events.any((event) => event.levelUp);

  factory RewardSummaryModel.fromJson(Map<String, dynamic> json) {
    final profile = (json['profile'] as Map<String, dynamic>?) ?? const {};
    return RewardSummaryModel(
      events: ((json['events'] as List?) ?? [])
          .map((event) => RewardEventModel.fromJson(event as Map<String, dynamic>))
          .toList(),
      xp: profile['xp'] as int? ?? 0,
      level: profile['level'] as int? ?? 1,
      nbSkip: profile['nb_skip'] as int? ?? 0,
      currentStreak: profile['current_streak'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'events': events.map((event) => event.toJson()).toList(),
      'profile': {
        'xp': xp,
        'level': level,
        'nb_skip': nbSkip,
        'current_streak': currentStreak,
      },
    };
  }
}
