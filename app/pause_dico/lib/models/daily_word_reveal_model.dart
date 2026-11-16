import 'reward_summary_model.dart';
import 'word_model.dart';

/// Result of revealing (or skipping) the daily word
class DailyWordRevealModel {
  final WordModel word;
  final int skipsLeft;
  final bool liked;

  /// Rewards granted by this reveal / skip (xp, streak, new letter…)
  final RewardSummaryModel? rewards;

  const DailyWordRevealModel({
    required this.word,
    required this.skipsLeft,
    this.liked = false,
    this.rewards,
  });

  factory DailyWordRevealModel.fromJson(Map<String, dynamic> json) {
    final rewards = json['rewards'] as Map<String, dynamic>?;
    return DailyWordRevealModel(
      word: WordModel.fromJson(json['word'] as Map<String, dynamic>),
      skipsLeft: json['nb_skip'] as int? ?? 0,
      liked: json['liked'] as bool? ?? false,
      rewards: rewards == null ? null : RewardSummaryModel.fromJson(rewards),
    );
  }

  DailyWordRevealModel copyWith({bool? liked, int? skipsLeft}) {
    return DailyWordRevealModel(
      word: word,
      skipsLeft: skipsLeft ?? this.skipsLeft,
      liked: liked ?? this.liked,
      rewards: rewards,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word.toJson(),
      'nb_skip': skipsLeft,
      'liked': liked,
      'rewards': rewards?.toJson(),
    };
  }
}
