import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  static const Color primaryColor = Color(0xFF1565C0);
  static const Color secondaryColor = Color(0xFF0D47A1);
  static const Color accentColor = Color(0xFF42A5F5);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);

  // Dimensions
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double spacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double largeSpacing = 24.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Font Sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 20.0;
  static const double fontSizeXLarge = 24.0;

  // Language Maps
  static const Map<String, String> languagesMapTTS = {
    'afrikaans': 'af-ZA',
    'albanian': 'sq-AL',
    'arabic': 'ar',
    'belarusian': 'be-BY',
    'bengali': 'bn-IN',
    'bulgarian': 'bg-BG',
    'catalan': 'ca',
    'chinese': 'zh-CN',
    'croatian': 'hr',
    'czech': 'cs-CZ',
    'danish': 'da-DK',
    'dutch': 'nl-NL',
    'english': 'en-US',
    'esperanto': 'eo',
    'estonian': 'et-EE',
    'finnish': 'fi-FI',
    'french': 'fr-FR',
    'galician': 'gl',
    'georgian': 'ka-GE',
    'german': 'de-DE',
    'greek': 'el-GR',
    'gujarati': 'gu-IN',
    'haitian': 'ht',
    'hebrew': 'he-IL',
    'hindi': 'hi-IN',
    'hungarian': 'hu-HU',
    'icelandic': 'is-IS',
    'indonesian': 'id-ID',
    'irish': 'ga-IE',
    'italian': 'it-IT',
    'japanese': 'ja-JP',
    'kannada': 'kn-IN',
    'korean': 'ko-KR',
    'latvian': 'lv-LV',
    'lithuanian': 'lt-LT',
    'macedonian': 'mk-MK',
    'malay': 'ms-MY',
    'maltese': 'mt-MT',
    'marathi': 'mr-IN',
    'norwegian': 'nb-NO',
    'persian': 'fa-IR',
    'polish': 'pl-PL',
    'portuguese': 'pt-PT',
    'romanian': 'ro-RO',
    'russian': 'ru-RU',
    'slovak': 'sk-SK',
    'slovenian': 'sl-SI',
    'spanish': 'es-ES',
    'swahili': 'sw-KE',
    'swedish': 'sv-SE',
    'tagalog': 'fil-PH',
    'tamil': 'ta-IN',
    'telugu': 'te-IN',
    'thai': 'th-TH',
    'turkish': 'tr-TR',
    'ukrainian': 'uk-UA',
    'urdu': 'ur-PK',
    'vietnamese': 'vi-VN',
    'welsh': 'cy',
  };

  static const Map<String, String> languagesMap = {
    'afrikaans': 'af_ZA',
    'albanian': 'sq_AL',
    'arabic': 'ar',
    'belarusian': 'be_BY',
    'bengali': 'bn_IN',
    'bulgarian': 'bg_BG',
    'catalan': 'ca',
    'chinese': 'zh_CN',
    'croatian': 'hr',
    'czech': 'cs_CZ',
    'danish': 'da_DK',
    'dutch': 'nl_NL',
    'english': 'en_US',
    'esperanto': 'eo',
    'estonian': 'et_EE',
    'finnish': 'fi_FI',
    'french': 'fr_FR',
    'galician': 'gl',
    'georgian': 'ka_GE',
    'german': 'de_DE',
    'greek': 'el_GR',
    'gujarati': 'gu_IN',
    'haitian': 'ht',
    'hebrew': 'he_IL',
    'hindi': 'hi_IN',
    'hungarian': 'hu_HU',
    'icelandic': 'is_IS',
    'indonesian': 'id_ID',
    'irish': 'ga_IE',
    'italian': 'it_IT',
    'japanese': 'ja_JP',
    'kannada': 'kn_IN',
    'korean': 'ko_KR',
    'latvian': 'lv_LV',
    'lithuanian': 'lt_LT',
    'macedonian': 'mk_MK',
    'malay': 'ms_MY',
    'maltese': 'mt_MT',
    'marathi': 'mr_IN',
    'norwegian': 'nb_NO',
    'persian': 'fa_IR',
    'polish': 'pl_PL',
    'portuguese': 'pt_PT',
    'romanian': 'ro_RO',
    'russian': 'ru_RU',
    'slovak': 'sk_SK',
    'slovenian': 'sl_SI',
    'spanish': 'es_ES',
    'swahili': 'sw_KE',
    'swedish': 'sv_SE',
    'tagalog': 'fil_PH',
    'tamil': 'ta_IN',
    'telugu': 'te_IN',
    'thai': 'th_TH',
    'turkish': 'tr_TR',
    'ukrainian': 'uk_UA',
    'urdu': 'ur_PK',
    'vietnamese': 'vi_VN',
    'welsh': 'cy',
  };

  // Popular language pairs for quick access
  static const List<Map<String, String>> popularLanguagePairs = [
    {'source': 'english', 'target': 'spanish'},
    {'source': 'english', 'target': 'french'},
    {'source': 'english', 'target': 'german'},
    {'source': 'english', 'target': 'chinese'},
    {'source': 'english', 'target': 'japanese'},
    {'source': 'spanish', 'target': 'english'},
    {'source': 'french', 'target': 'english'},
    {'source': 'chinese', 'target': 'english'},
  ];

  // Language display names with flags
  static const Map<String, Map<String, String>> languageInfo = {
    'english': {'flag': '🇺🇸', 'name': 'English'},
    'spanish': {'flag': '🇪🇸', 'name': 'Spanish'},
    'french': {'flag': '🇫🇷', 'name': 'French'},
    'german': {'flag': '🇩🇪', 'name': 'German'},
    'chinese': {'flag': '🇨🇳', 'name': 'Chinese'},
    'japanese': {'flag': '🇯🇵', 'name': 'Japanese'},
    'korean': {'flag': '🇰🇷', 'name': 'Korean'},
    'arabic': {'flag': '🇸🇦', 'name': 'Arabic'},
    'hindi': {'flag': '🇮🇳', 'name': 'Hindi'},
    'portuguese': {'flag': '🇵🇹', 'name': 'Portuguese'},
    'russian': {'flag': '🇷🇺', 'name': 'Russian'},
    'italian': {'flag': '🇮🇹', 'name': 'Italian'},
    'dutch': {'flag': '🇳🇱', 'name': 'Dutch'},
    'vietnamese': {'flag': '🇻🇳', 'name': 'Vietnamese'},
  };

  // Error Messages
  static const String errorNetworkConnection =
      'Please check your internet connection';
  static const String errorTranslationFailed =
      'Translation failed. Please try again';
  static const String errorModelDownloadFailed =
      'Failed to download language model';
  static const String errorSpeechNotSupported =
      'Speech recognition not supported for this language';
  static const String errorImageProcessingFailed = 'Failed to process image';
  static const String errorPermissionDenied = 'Permission denied';

  // Success Messages
  static const String successTranslationCompleted = 'Translation completed';
  static const String successModelDownloaded =
      'Language model downloaded successfully';
  static const String successTextCopied = 'Text copied to clipboard';
}
