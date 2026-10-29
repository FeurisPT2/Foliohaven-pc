import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService instance = TtsService._internal();
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  VoidCallback? onStateChanged;

  Future<void> init() async {
    try {
      _flutterTts.setStartHandler(() {
        _isPlaying = true;
        onStateChanged?.call();
      });

      _flutterTts.setCompletionHandler(() {
        _isPlaying = false;
        onStateChanged?.call();
      });

      _flutterTts.setErrorHandler((msg) {
        _isPlaying = false;
        onStateChanged?.call();
      });

      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);
    } catch (e) {
      debugPrint('TTS initialization notice: $e');
    }
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    try {
      _isPlaying = true;
      onStateChanged?.call();
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('TTS speak error: $e');
      _isPlaying = false;
      onStateChanged?.call();
    }
  }

  Future<void> stop() async {
    try {
      _isPlaying = false;
      onStateChanged?.call();
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
  }

  Future<void> pause() async {
    try {
      _isPlaying = false;
      onStateChanged?.call();
      await _flutterTts.pause();
    } catch (e) {
      debugPrint('TTS pause error: $e');
    }
  }
}
