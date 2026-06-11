import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  static final stt.SpeechToText _speech = stt.SpeechToText();
  static final FlutterTts _tts = FlutterTts();

  // 初始化语音引擎
  static Future<bool> initSpeech() async {
    return await _speech.initialize();
  }

  // 开始语音转文字
  static void startListen({
    required Function(String text) onResult,
    required VoidCallback onStop,
  }) async {
    if (!await initSpeech()) return;

    _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      onSoundLevelChange: (level) {},
      listenFor: const Duration(seconds: 30),
    );
  }

  // 停止语音监听
  static void stopListen() {
    _speech.stop();
  }

  // 语音播报文本
  static Future<void> speak(String text) async {
    await _tts.setLanguage("zh-CN");
    await _tts.setSpeechRate(0.9);
    await _tts.speak(text);
  }

  // 停止播报
  static Future<void> stopSpeak() async {
    await _tts.stop();
  }
}