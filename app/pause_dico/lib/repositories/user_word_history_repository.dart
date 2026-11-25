import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/date_helpers.dart';
import '../models/daily_word_choice_model.dart';
import '../models/daily_word_reveal_model.dart';
import '../models/user_word_history_model.dart';
import '../models/word_model.dart';

class UserWordHistoryRepository {
  final SupabaseClient _client;

  UserWordHistoryRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Selects the history date and like along with the joined word
  static const String _selectWithWord =
      'date, liked, word:${AppConstants.wordTable}!user_word_history_word_id_fkey(id, name, gender, type, theme, definition)';

  String? get _userId => _client.auth.currentUser?.id;

  /// In-memory caches keyed by ISO date ('YYYY-MM-DD'), kept up to date by
  /// reveal / like. A cached null means "no word on that date".
  final Map<String, UserWordHistoryModel?> _entryCache = {};
  final Map<String, List<WordModel>> _weekCache = {};

  /// Gets all the words learned by the logged-in user, most recent first
  /// (one call: a user learns at most one word a day)
  Future<List<UserWordHistoryModel>> getAllWords() async {
    final userId = _userId;
    if (userId == null) return [];

    final response = await _client
        .from(AppConstants.userWordHistoryTable)
        .select(_selectWithWord)
        .eq('user_id', userId)
        .order('date', ascending: false);

    return response.map(UserWordHistoryModel.fromJson).toList();
  }

  /// Gets the history entry of the logged-in user for the given date.
  /// Served from cache unless [forceRefresh] is set.
  Future<UserWordHistoryModel?> getWordByDate(
    DateTime date, {
    bool forceRefresh = false,
  }) async {
    final userId = _userId;
    if (userId == null) return null;

    final key = DateHelpers.toIsoDateString(date);
    if (!forceRefresh && _entryCache.containsKey(key)) return _entryCache[key];

    final response = await _client
        .from(AppConstants.userWordHistoryTable)
        .select(_selectWithWord)
        .eq('user_id', userId)
        .eq('date', key)
        .maybeSingle();

    return _entryCache[key] =
        response == null ? null : UserWordHistoryModel.fromJson(response);
  }

  /// Gets the words discovered by the user that start with [letter]
  /// (normalized first letter: É -> E), sorted by name
  Future<List<WordModel>> getWordsByLetter(String letter) async {
    final userId = _userId;
    if (userId == null) return [];

    final response = await _client
        .from(AppConstants.userWordHistoryTable)
        .select(
          'word:${AppConstants.wordTable}!user_word_history_word_id_fkey!inner(id, name, gender, type, theme, definition)',
        )
        .eq('user_id', userId)
        .eq('word.first_letter', letter);

    return response.map((row) => WordModel.fromJson(row['word'])).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Gets the words learned from Monday to Saturday of the week ending on [sunday].
  /// Served from cache unless [forceRefresh] is set.
  Future<List<WordModel>> getWeekWords(
    DateTime sunday, {
    bool forceRefresh = false,
  }) async {
    final userId = _userId;
    if (userId == null) return [];

    final key = DateHelpers.toIsoDateString(sunday);
    final cached = _weekCache[key];
    if (!forceRefresh && cached != null) return cached;

    final response = await _client
        .from(AppConstants.userWordHistoryTable)
        .select(_selectWithWord)
        .eq('user_id', userId)
        .gte('date', DateHelpers.toIsoDateString(DateHelpers.weekStart(sunday)))
        .lte('date', DateHelpers.toIsoDateString(DateHelpers.weekEnd(sunday)))
        .order('date', ascending: true);

    return _weekCache[key] =
        response.map((row) => WordModel.fromJson(row['word'])).toList();
  }

  /// Stores the word revealed on [date] in the cache
  DailyWordRevealModel _cacheReveal(DateTime date, DailyWordRevealModel reveal) {
    _entryCache[DateHelpers.toIsoDateString(date)] = UserWordHistoryModel(
      word: reveal.word,
      date: DateHelpers.dateOnly(date),
      liked: reveal.liked,
    );
    _weekCache.clear();
    return reveal;
  }

  /// Gets the 3 daily word candidates of [date] (name and theme), picked
  /// server-side once per day among words the user never had: the same 3
  /// come back until one is chosen
  Future<List<DailyWordChoiceModel>> getDailyChoices(DateTime date) async {
    final response = await _client.rpc(
      AppConstants.getDailyChoicesRpc,
      params: {'p_date': DateHelpers.toIsoDateString(date)},
    );
    return (response as List)
        .map((json) => DailyWordChoiceModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Reveals the candidate [wordId] chosen for [date]: saves it into the
  /// history (idempotent) and returns it with its definition and rewards
  Future<DailyWordRevealModel> revealDailyWord(DateTime date, int wordId) async {
    final response = await _client.rpc(
      AppConstants.revealDailyWordRpc,
      params: {'p_date': DateHelpers.toIsoDateString(date), 'p_word_id': wordId},
    );
    return _cacheReveal(
      date,
      DailyWordRevealModel.fromJson(response as Map<String, dynamic>),
    );
  }

  /// Likes / unlikes a word of the history and returns the saved state
  Future<bool> setWordLiked(int wordId, bool liked) async {
    final response = await _client.rpc(
      AppConstants.setWordLikedRpc,
      params: {'p_word_id': wordId, 'p_liked': liked},
    );
    final saved = response as bool;

    for (final entry in _entryCache.entries.toList()) {
      final value = entry.value;
      if (value != null && value.word.id == wordId) {
        _entryCache[entry.key] = value.copyWith(liked: saved);
      }
    }
    return saved;
  }

  /// Checks if the logged-in user has already acknowledged this word
  Future<bool> isWordAcknowledged(int wordId) async {
    final userId = _userId;
    if (userId == null) return false;

    final response = await _client
        .from(AppConstants.userWordHistoryTable)
        .select('word_id')
        .eq('user_id', userId)
        .eq('word_id', wordId)
        .maybeSingle();

    return response != null;
  }
}
