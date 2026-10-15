import 'package:url_launcher/url_launcher.dart';

import '../core/constants/app_constants.dart';

/// Opens external web links in the browser
class LinkService {
  /// Wiktionary page URL for a word (lowercased name)
  static Uri wiktionaryUri(String wordName) => Uri.parse(
    '${AppConstants.wiktionaryBaseUrl}${Uri.encodeComponent(wordName.toLowerCase())}',
  );

  /// Opens [uri] in the external browser. Returns false if it failed.
  static Future<bool> open(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);
}
