import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final FlutterTts _tts = FlutterTts();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    // Print available engines (VERY important)
    var engines = await _tts.getEngines;
    print("AVAILABLE TTS ENGINES: $engines");

    // Try forcing Google TTS if available
    if (engines.contains("com.google.android.tts")) {
      await _tts.setEngine("com.google.android.tts");
      print("Google TTS engine selected");
    }

    // Print languages for debugging
    var languages = await _tts.getLanguages;
    print("AVAILABLE LANGUAGES: $languages");

    // Set language — fallback to a universal one
    try {
      await _tts.setLanguage("en-US");
    } catch (e) {
      print("en-US not available, switching to en-GB");
      await _tts.setLanguage("en-GB");
    }

    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);

    // Debug handlers
    _tts.setStartHandler(() => print("TTS STARTED"));
    _tts.setCompletionHandler(() => print("TTS FINISHED"));
    _tts.setErrorHandler((err) => print("TTS ERROR: $err"));

    _initialized = true;
  }

  static Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  static Future<void> stop() async {
    await _tts.stop();
  }
}
