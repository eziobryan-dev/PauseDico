import 'package:share_plus/share_plus.dart';

import '../core/constants/app_constants.dart';
import '../models/word_model.dart';

/// Shares a word through the OS share sheet (messages, social networks…)
abstract class WordShareService {
  static Future<void> share(WordModel word) {
    final type = word.type.isEmpty ? '' : ' (${word.type})';
    return SharePlus.instance.share(
      ShareParams(
        subject: '${word.name} · ${AppConstants.appName}',
        text: '📖 ${word.name}$type\n'
            '${word.definition}\n\n'
            '${AppConstants.shareSignature}',
      ),
    );
  }
}
