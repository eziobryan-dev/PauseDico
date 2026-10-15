import 'package:flutter/material.dart';

import '../core/utils/text_helpers.dart';
import '../models/user_word_history_model.dart';
import '../repositories/user_word_history_repository.dart';
import '../widgets/feature_card.dart';
import '../widgets/notebook_entry_tile.dart';
import '../widgets/word_detail_sheet.dart';
import '../widgets/screen_title.dart';

/// "Mon carnet": every learned word, searchable (accent-insensitive), with a
/// favorites filter. Loaded in one call, filtered locally.
class NotebookScreen extends StatefulWidget {
  const NotebookScreen({super.key});

  @override
  State<NotebookScreen> createState() => _NotebookScreenState();
}

class _NotebookScreenState extends State<NotebookScreen> {
  final UserWordHistoryRepository _historyRepository = UserWordHistoryRepository();

  List<UserWordHistoryModel> _entries = [];
  bool _isLoading = true;
  bool _hasError = false;
  bool _favoritesOnly = false;
  String _query = '';

  List<UserWordHistoryModel> get _visibleEntries {
    final query = TextHelpers.normalize(_query.trim());
    return _entries.where((entry) {
      if (_favoritesOnly && !entry.liked) return false;
      if (query.isEmpty) return true;
      return TextHelpers.normalize(entry.word.name).contains(query) ||
          TextHelpers.normalize(entry.word.definition).contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final entries = await _historyRepository.getAllWords();
      if (mounted) setState(() => _entries = entries);
    } catch (e) {
      if (mounted) setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _setLiked(UserWordHistoryModel entry, bool liked) async {
    final saved = await _historyRepository.setWordLiked(entry.word.id, liked);
    if (mounted) {
      setState(() {
        _entries = [
          for (final e in _entries)
            e.word.id == entry.word.id ? e.copyWith(liked: saved) : e,
        ];
      });
    }
    return saved;
  }

  void _openEntry(UserWordHistoryModel entry) {
    WordDetailSheet.show(
      context,
      word: entry.word,
      liked: entry.liked,
      onLikeChanged: (liked) => _setLiked(entry, liked),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const ScreenTitle('Mon carnet')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Rechercher un mot ou une définition',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                isDense: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  avatar: const Icon(Icons.favorite, size: 18),
                  label: const Text('Favoris'),
                  selected: _favoritesOnly,
                  onSelected: (value) => setState(() => _favoritesOnly = value),
                ),
                const Spacer(),
                if (!_isLoading) Text('${_visibleEntries.length} mot(s)'),
              ],
            ),
          ),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_hasError) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: FeatureCard(
          tone: FeatureCardTone.error,
          icon: Icons.error_outline,
          message: 'Impossible de charger ton carnet.',
          actionLabel: 'Réessayer',
          actionIcon: Icons.refresh,
          onAction: _load,
        ),
      );
    }

    final entries = _visibleEntries;
    if (entries.isEmpty) {
      return Center(
        child: Text(
          _entries.isEmpty
              ? 'Ton carnet est vide : révèle ton premier mot du jour !'
              : 'Aucun mot ne correspond.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        itemCount: entries.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, i) => NotebookEntryTile(
          entry: entries[i],
          onTap: () => _openEntry(entries[i]),
        ),
      ),
    );
  }
}
