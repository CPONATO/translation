import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import '../constants/constants.dart';

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _speechEnabled = false;
  List<LocaleName> _availableLocales = [];

  bool get isListening => _speechToText.isListening;
  bool get speechEnabled => _speechEnabled;
  List<LocaleName> get availableLocales => _availableLocales;

  Future<void> initialize() async {
    _speechEnabled = await _speechToText.initialize();
    if (_speechEnabled) {
      _availableLocales = await _speechToText.locales();
    }

    // Configure TTS
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> startListening({
    required Function(SpeechRecognitionResult) onResult,
    String? localeId,
  }) async {
    if (!_speechEnabled) return;

    await _speechToText.listen(
      onResult: onResult,
      localeId: localeId ?? 'en_US',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  Future<void> speak(String text, {String? languageCode}) async {
    if (languageCode != null) {
      await _flutterTts.setLanguage(languageCode);
    }
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  bool isLocaleSupported(String localeId) {
    return _availableLocales.any((locale) => locale.localeId == localeId);
  }

  String? getLocaleForLanguage(String languageName) {
    return AppConstants.languagesMap[languageName.toLowerCase()];
  }

  String? getTTSLanguageCode(String languageName) {
    return AppConstants.languagesMapTTS[languageName.toLowerCase()];
  }
}
