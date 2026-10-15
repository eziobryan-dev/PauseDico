import 'package:flutter_tts/flutter_tts.dart';

/// Reads words aloud with the device's French text-to-speech voice
abstract class PronunciationService {
  static final FlutterTts _tts = FlutterTts();
  static bool _isConfigured = false;

  static Future<void> speak(String text) async {
    if (!_isConfigured) {
      await _tts.setLanguage('fr-FR');
      await _tts.setSpeechRate(0.45);
      _isConfigured = true;
    }
    await _tts.stop();
    await _tts.speak(text);
  }
}
