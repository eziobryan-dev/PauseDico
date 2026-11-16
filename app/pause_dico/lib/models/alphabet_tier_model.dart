/// Stage of the Alphadex: gold first, then emerald once the 26 gold letters
/// are unlocked. Letters, bookmarks and fragments are named after it.
enum AlphabetTier {
  gold('gold', 'doré', 'dorée', 'dorés', 'dorées'),
  emerald('emerald', "d'émeraude", "d'émeraude", "d'émeraude", "d'émeraude");

  final String dbValue;
  final String masculine;
  final String feminine;
  final String masculinePlural;
  final String femininePlural;

  const AlphabetTier(
    this.dbValue,
    this.masculine,
    this.feminine,
    this.masculinePlural,
    this.femininePlural,
  );

  static AlphabetTier fromDb(String? value) =>
      value == emerald.dbValue ? emerald : gold;

  String get bookmarkName => 'marque-page $masculine';
  String get fragmentName => 'fragment de marque-page $masculine';
  String get alphadexName => 'Alphadex $masculine';
}
