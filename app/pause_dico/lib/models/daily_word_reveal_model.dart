import 'reward_summary_model.dart';
import 'word_model.dart';

/// Result of revealing the daily word
class DailyWordRevealModel {
  final WordModel word;
  final bool liked;

  /// Rewards granted by this reveal (xp, streak, new letter…)
  final RewardSummaryModel? rewards;

  const DailyWordRevealModel({
    required this.word,
    this.liked = false,
    this.rewards,
  });

  factory DailyWordRevealModel.fromJson(Map<String, dynamic> json) {
    final rewards = json['rewards'] as Map<String, dynamic>?;
    return DailyWordRevealModel(
      word: WordModel.fromJson(json['word'] as Map<String, dynamic>),
      liked: json['liked'] as bool? ?? false,
      rewards: rewards == null ? null : RewardSummaryModel.fromJson(rewards),
    );
  }

  DailyWordRevealModel copyWith({bool? liked}) {
    return DailyWordRevealModel(
      word: word,
      liked: liked ?? this.liked,
      rewards: rewards,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word.toJson(),
      'liked': liked,
      'rewards': rewards?.toJson(),
    };
  }
}
