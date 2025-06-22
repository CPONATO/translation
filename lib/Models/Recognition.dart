import 'dart:ui';

class Recognition {
  final String translation;
  final String originalText;
  final Rect boundingBox;
  final double confidence;

  Recognition({
    required this.translation,
    required this.originalText,
    required this.boundingBox,
    this.confidence = 1.0,
  });

  Recognition copyWith({
    String? translation,
    String? originalText,
    Rect? boundingBox,
    double? confidence,
  }) {
    return Recognition(
      translation: translation ?? this.translation,
      originalText: originalText ?? this.originalText,
      boundingBox: boundingBox ?? this.boundingBox,
      confidence: confidence ?? this.confidence,
    );
  }
}
