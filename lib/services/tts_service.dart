import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;

  TtsService() {
    _initTTS();
  }

  Future<void> _initTTS() async {
    await _tts.setLanguage('en-US');
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.4);
    await _tts.setVolume(1.0);
  }

  Future<void> speakWord(String word) async {
    if (word.isEmpty) return;

    try {
      if (_isSpeaking) {
        await _tts.stop();
      }

      setStateIfPossible(() {
        _isSpeaking = true;
      });

      await _tts.speak(word);

      _tts.setCompletionHandler(() {
        setStateIfPossible(() {
          _isSpeaking = false;
        });
      });

    } catch (e) {
      print('Lỗi TTS: $e');
      setStateIfPossible(() {
        _isSpeaking = false;
      });
    }
  }

  Future<void> stop() async {
    await _tts.stop();
    setStateIfPossible(() {
      _isSpeaking = false;
    });
  }

  void setStateIfPossible(void Function() fn) {
    try {
      fn();
    } catch (e) {
      // Bỏ qua nếu không có setState
    }
  }

  void dispose() {
    _tts.stop();
  }
}