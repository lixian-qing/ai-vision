import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  static final stt.SpeechToText _speech = stt.SpeechToText();
  static final FlutterTts _tts = FlutterTts();
  static bool _initialized = false;

  static Future<bool> initSpeech() async {
    if (_initialized) return true;
    _initialized = await _speech.initialize();
    return _initialized;
  }

  static void startListen({
    required Function(String text) onResult,
    required VoidCallback onStop,
  }) async {
    if (!await initSpeech()) return;

    _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
        if (result.finalResult) {
          onStop();
        }
      },
      listenFor: const Duration(seconds: 30),
    );
  }

  static void stopListen() {
    _speech.stop();
  }

  static Future<void> speak(String text) async {
    await _tts.setLanguage("zh-CN");
    await _tts.setSpeechRate(0.9);
    await _tts.speak(text);
  }

  static Future<void> stopSpeak() async {
    await _tts.stop();
  }
}
