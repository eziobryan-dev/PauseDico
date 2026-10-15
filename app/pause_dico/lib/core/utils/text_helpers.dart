abstract class TextHelpers {
  static const _accents = 'àâäáãåçéèêëíìîïñóòôöõúùûüýÿœæ';
  static const _plain = 'aaaaaaceeeeiiiinooooouuuuyyoa';

  /// Lowercase without accents, for accent-insensitive search
  /// ("Étoile" -> "etoile")
  static String normalize(String text) {
    final lower = text.toLowerCase();
    final buffer = StringBuffer();
    for (final char in lower.split('')) {
      final index = _accents.indexOf(char);
      buffer.write(index == -1 ? char : _plain[index]);
    }
    return buffer.toString();
  }
}
