enum TranslationStatus { initial, loading, translating, completed, error }

class TranslationState {
  final TranslationStatus status;
  final String inputText;
  final String translatedText;
  final String? errorMessage;
  final bool isAutoDetecting;
  final double progress;

  const TranslationState({
    this.status = TranslationStatus.initial,
    this.inputText = '',
    this.translatedText = '',
    this.errorMessage,
    this.isAutoDetecting = false,
    this.progress = 0.0,
  });

  TranslationState copyWith({
    TranslationStatus? status,
    String? inputText,
    String? translatedText,
    String? errorMessage,
    bool? isAutoDetecting,
    double? progress,
  }) {
    return TranslationState(
      status: status ?? this.status,
      inputText: inputText ?? this.inputText,
      translatedText: translatedText ?? this.translatedText,
      errorMessage: errorMessage ?? this.errorMessage,
      isAutoDetecting: isAutoDetecting ?? this.isAutoDetecting,
      progress: progress ?? this.progress,
    );
  }
}
