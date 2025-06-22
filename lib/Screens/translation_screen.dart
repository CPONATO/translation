import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import '../constants/constants.dart';
import '../models/language_pair.dart';
import '../models/translation_state.dart';
import '../services/translation_service.dart';
import '../services/speech_service.dart';
import '../widgets/language_selector.dart';
import '../widgets/translation_input_card.dart';
import '../widgets/translation_output_card.dart';
import '../widgets/action_buttons.dart';
import '../widgets/loading_overlay.dart';
import 'vision_screen.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen>
    with TickerProviderStateMixin {
  // Services
  final _translationService = TranslationService();
  final _speechService = SpeechService();

  // Controllers
  final _inputController = TextEditingController();
  late AnimationController _fadeController;
  late AnimationController _slideController;

  // State
  LanguagePair _currentLanguagePair = const LanguagePair(
    source: TranslateLanguage.english,
    target: TranslateLanguage.vietnamese,
  );

  TranslationState _translationState = const TranslationState();
  bool _isAutoDetectEnabled = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeServices();
    _setupListeners();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: AppConstants.longAnimation,
      vsync: this,
    );
    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _initializeServices() async {
    try {
      await _speechService.initialize();
      await _translationService.initializeTranslator(_currentLanguagePair);
    } catch (e) {
      _showErrorSnackBar('Initialization failed: $e');
    }
  }

  void _setupListeners() {
    _translationService.stateStream.listen((state) {
      if (mounted) {
        setState(() {
          _translationState = state;
        });
      }
    });

    _inputController.addListener(() {
      if (_inputController.text.isNotEmpty) {
        _debounceTranslation();
      }
    });
  }

  Timer? _debounceTimer;
  void _debounceTranslation() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_isAutoDetectEnabled) {
        _detectAndTranslate();
      } else {
        _performTranslation();
      }
    });
  }

  Future<void> _detectAndTranslate() async {
    try {
      final detectedLanguage = await _translationService.detectLanguage(
        _inputController.text,
      );

      if (detectedLanguage != _currentLanguagePair.source) {
        setState(() {
          _currentLanguagePair = _currentLanguagePair.copyWith(
            source: detectedLanguage,
          );
        });
        await _translationService.initializeTranslator(_currentLanguagePair);
      }

      await _performTranslation();
    } catch (e) {
      _showErrorSnackBar('Language detection failed: $e');
    }
  }

  Future<void> _performTranslation() async {
    if (_inputController.text.isEmpty) return;

    try {
      await _translationService.translateText(_inputController.text);
    } catch (e) {
      _showErrorSnackBar('Translation failed: $e');
    }
  }

  Future<void> _onLanguagePairChanged(LanguagePair newPair) async {
    if (newPair != _currentLanguagePair) {
      setState(() {
        _currentLanguagePair = newPair;
      });
      await _translationService.initializeTranslator(newPair);
      if (_inputController.text.isNotEmpty) {
        await _performTranslation();
      }
    }
  }

  void _swapLanguages() {
    _onLanguagePairChanged(_currentLanguagePair.swapped());
    final temp = _inputController.text;
    _inputController.text = _translationState.translatedText;
    // Note: We'd need to trigger translation here for the swapped text
  }

  Future<void> _startListening() async {
    if (!_speechService.speechEnabled) {
      _showErrorSnackBar('Speech recognition not available');
      return;
    }

    setState(() {
      _isListening = true;
    });

    final localeId = _speechService.getLocaleForLanguage(
      _currentLanguagePair.source.name,
    );

    if (localeId == null || !_speechService.isLocaleSupported(localeId)) {
      _showErrorSnackBar(
        'Speech recognition not supported for ${_currentLanguagePair.source.name}',
      );
      setState(() {
        _isListening = false;
      });
      return;
    }

    try {
      await _speechService.startListening(
        onResult: _onSpeechResult,
        localeId: localeId,
      );
    } catch (e) {
      _showErrorSnackBar('Failed to start listening: $e');
      setState(() {
        _isListening = false;
      });
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _inputController.text = result.recognizedWords;
      if (result.finalResult) {
        _isListening = false;
      }
    });

    if (result.finalResult) {
      _performTranslation();
    }
  }

  Future<void> _stopListening() async {
    await _speechService.stopListening();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _speakTranslation() async {
    if (_translationState.translatedText.isEmpty) return;

    final languageCode = _speechService.getTTSLanguageCode(
      _currentLanguagePair.target.name,
    );

    try {
      await _speechService.speak(
        _translationState.translatedText,
        languageCode: languageCode,
      );
    } catch (e) {
      _showErrorSnackBar('Text-to-speech failed: $e');
    }
  }

  void _copyTranslation() {
    if (_translationState.translatedText.isEmpty) return;

    Clipboard.setData(ClipboardData(text: _translationState.translatedText));
    _showSuccessSnackBar('Text copied to clipboard');
  }

  Future<void> _navigateToVisionScreen(ImageSource source) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder:
            (context) => VisionScreen(
              imageSource: source,
              languagePair: _currentLanguagePair,
            ),
      ),
    );

    if (result != null) {
      _inputController.text = result;
      await _performTranslation();
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _inputController.dispose();
    _debounceTimer?.cancel();
    _speechService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(),
      body: LoadingOverlay(
        isLoading: _translationState.status == TranslationStatus.loading,
        progress: _translationState.progress,
        child: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppConstants.primaryColor,
      title: const Text(
        'Smart Translator',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
      actions: [
        AnimatedSwitcher(
          duration: AppConstants.shortAnimation,
          child: Switch(
            key: ValueKey(_isAutoDetectEnabled),
            value: _isAutoDetectEnabled,
            onChanged: (value) {
              setState(() {
                _isAutoDetectEnabled = value;
              });
            },
            activeColor: AppConstants.accentColor,
          ),
        ),
        const SizedBox(width: AppConstants.spacing),
      ],
    );
  }

  Widget _buildBody() {
    return FadeTransition(
      opacity: _fadeController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacing),
          child: Column(
            children: [
              // Input Section
              Expanded(
                flex: 3,
                child: TranslationInputCard(
                  controller: _inputController,
                  isListening: _isListening,
                  onClear: () => _inputController.clear(),
                ),
              ),

              const SizedBox(height: AppConstants.spacing),

              // Language Selector
              LanguageSelector(
                languagePair: _currentLanguagePair,
                onLanguagePairChanged: _onLanguagePairChanged,
                onSwapLanguages: _swapLanguages,
                isAutoDetectEnabled: _isAutoDetectEnabled,
              ),

              const SizedBox(height: AppConstants.spacing),

              // Output Section
              Expanded(
                flex: 3,
                child: TranslationOutputCard(
                  text: _translationState.translatedText,
                  isLoading:
                      _translationState.status == TranslationStatus.translating,
                  onCopy: _copyTranslation,
                  onSpeak: _speakTranslation,
                ),
              ),

              const SizedBox(height: AppConstants.spacing),

              // Action Buttons
              ActionButtons(
                isListening: _isListening,
                onMicPressed: _isListening ? _stopListening : _startListening,
                onCameraPressed:
                    () => _navigateToVisionScreen(ImageSource.camera),
                onGalleryPressed:
                    () => _navigateToVisionScreen(ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
