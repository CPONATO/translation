import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class LanguagePair {
  final TranslateLanguage source;
  final TranslateLanguage target;

  const LanguagePair({required this.source, required this.target});

  LanguagePair copyWith({
    TranslateLanguage? source,
    TranslateLanguage? target,
  }) {
    return LanguagePair(
      source: source ?? this.source,
      target: target ?? this.target,
    );
  }

  LanguagePair swapped() {
    return LanguagePair(source: target, target: source);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LanguagePair &&
        other.source == source &&
        other.target == target;
  }

  @override
  int get hashCode => source.hashCode ^ target.hashCode;
}
