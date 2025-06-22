// lib/services/translation_service.dart
import 'dart:async';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/language_pair.dart';
import '../models/translation_state.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
  final _modelManager = OnDeviceTranslatorModelManager();
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  OnDeviceTranslator? _currentTranslator;
  LanguagePair? _currentLanguagePair;

  final _stateController = StreamController<TranslationState>.broadcast();
  Stream<TranslationState> get stateStream => _stateController.stream;

  TranslationState _currentState = const TranslationState();
  TranslationState get currentState => _currentState;

  void _updateState(TranslationState newState) {
    _currentState = newState;
    _stateController.add(_currentState);
  }

  Future<void> initializeTranslator(LanguagePair languagePair) async {
    if (_currentLanguagePair == languagePair && _currentTranslator != null) {
      return; // Already initialized
    }

    _updateState(
      _currentState.copyWith(status: TranslationStatus.loading, progress: 0.1),
    );

    try {
      await _ensureModelsDownloaded(languagePair);

      _currentTranslator?.close();
      _currentTranslator = OnDeviceTranslator(
        sourceLanguage: languagePair.source,
        targetLanguage: languagePair.target,
      );
      _currentLanguagePair = languagePair;

      _updateState(
        _currentState.copyWith(
          status: TranslationStatus.completed,
          progress: 1.0,
        ),
      );
    } catch (e) {
      _updateState(
        _currentState.copyWith(
          status: TranslationStatus.error,
          errorMessage: 'Failed to initialize translator: $e',
        ),
      );
    }
  }

  Future<void> _ensureModelsDownloaded(LanguagePair languagePair) async {
    final sourceDownloaded = await _modelManager.isModelDownloaded(
      languagePair.source.bcpCode,
    );
    final targetDownloaded = await _modelManager.isModelDownloaded(
      languagePair.target.bcpCode,
    );

    if (!sourceDownloaded) {
      _updateState(_currentState.copyWith(progress: 0.3));
      await _modelManager.downloadModel(languagePair.source.bcpCode);
    }

    if (!targetDownloaded) {
      _updateState(_currentState.copyWith(progress: 0.7));
      await _modelManager.downloadModel(languagePair.target.bcpCode);
    }
  }

  Future<String> translateText(String text) async {
    if (_currentTranslator == null) {
      throw Exception('Translator not initialized');
    }

    _updateState(
      _currentState.copyWith(
        status: TranslationStatus.translating,
        inputText: text,
      ),
    );

    try {
      final result = await _currentTranslator!.translateText(text);

      _updateState(
        _currentState.copyWith(
          status: TranslationStatus.completed,
          translatedText: result,
        ),
      );

      return result;
    } catch (e) {
      _updateState(
        _currentState.copyWith(
          status: TranslationStatus.error,
          errorMessage: 'Translation failed: $e',
        ),
      );
      rethrow;
    }
  }

  Future<TranslateLanguage> detectLanguage(String text) async {
    try {
      final languageCode = await _languageIdentifier.identifyLanguage(text);

      return TranslateLanguage.values.firstWhere(
        (lang) => lang.bcpCode == languageCode,
        orElse: () => TranslateLanguage.english,
      );
    } catch (e) {
      return TranslateLanguage.english;
    }
  }

  Future<RecognizedText> recognizeTextFromImage(InputImage image) async {
    try {
      return await _textRecognizer.processImage(image);
    } catch (e) {
      throw Exception('Text recognition failed: $e');
    }
  }

  // XÓA method này vì không tồn tại trong API
  // Future<List<String>> getAvailableModels() async {
  //   return await _modelManager.getAvailableModels();
  // }

  Future<bool> isModelDownloaded(String languageCode) async {
    return await _modelManager.isModelDownloaded(languageCode);
  }

  void dispose() {
    _currentTranslator?.close();
    _languageIdentifier.close();
    _textRecognizer.close();
    _stateController.close();
  }
}
