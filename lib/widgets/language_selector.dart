import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import '../constants/constants.dart';
import '../models/language_pair.dart';

class LanguageSelector extends StatelessWidget {
  final LanguagePair languagePair;
  final Function(LanguagePair) onLanguagePairChanged;
  final VoidCallback onSwapLanguages;
  final bool isAutoDetectEnabled;

  const LanguageSelector({
    super.key,
    required this.languagePair,
    required this.onLanguagePairChanged,
    required this.onSwapLanguages,
    required this.isAutoDetectEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12), // ✅ Reduced padding
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        // ✅ Ensure consistent height
        child: Row(
          children: [
            Expanded(
              flex: 5, // ✅ More space for dropdowns
              child: _LanguageDropdown(
                language: languagePair.source,
                onChanged: (language) {
                  if (language != null) {
                    onLanguagePairChanged(
                      languagePair.copyWith(source: language),
                    );
                  }
                },
                label: isAutoDetectEnabled ? 'Auto-detect' : 'From',
                enabled: !isAutoDetectEnabled,
              ),
            ),

            const SizedBox(width: 8), // ✅ Minimal spacing

            _SwapButton(onPressed: onSwapLanguages),

            const SizedBox(width: 8), // ✅ Minimal spacing

            Expanded(
              flex: 5, // ✅ More space for dropdowns
              child: _LanguageDropdown(
                language: languagePair.target,
                onChanged: (language) {
                  if (language != null) {
                    onLanguagePairChanged(
                      languagePair.copyWith(target: language),
                    );
                  }
                },
                label: 'To',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageDropdown extends StatelessWidget {
  final TranslateLanguage language;
  final Function(TranslateLanguage?) onChanged;
  final String label;
  final bool enabled;

  const _LanguageDropdown({
    required this.language,
    required this.onChanged,
    required this.label,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // ✅ Minimize space
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11, // ✅ Even smaller font
              color: AppConstants.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 2), // ✅ Minimal spacing
        // Dropdown Container
        Container(
          height: 40, // ✅ Smaller fixed height
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  enabled
                      ? AppConstants.primaryColor.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(6), // ✅ Smaller radius
            color: enabled ? Colors.white : Colors.grey.shade100,
          ),
          child: DropdownButtonHideUnderline(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
              ), // ✅ Minimal padding
              child: DropdownButton<TranslateLanguage>(
                value: language,
                isExpanded: true,
                isDense: true, // ✅ Dense mode
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: enabled ? AppConstants.primaryColor : Colors.grey,
                  size: 16, // ✅ Smaller icon
                ),
                onChanged: enabled ? onChanged : null,
                style: TextStyle(
                  color: enabled ? AppConstants.textPrimaryColor : Colors.grey,
                  fontSize: 12, // ✅ Smaller font
                ),
                dropdownColor: AppConstants.cardColor,
                elevation: 8,
                menuMaxHeight: 250, // ✅ Smaller dropdown
                items:
                    TranslateLanguage.values.map((lang) {
                      final displayName = _getDisplayName(lang);
                      return DropdownMenuItem<TranslateLanguage>(
                        value: lang,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Flag (optional)
                            if (_hasFlag(lang)) ...[
                              Text(
                                _getFlag(lang),
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                            ],
                            // Language name
                            Flexible(
                              child: Text(
                                displayName,
                                style: TextStyle(
                                  color:
                                      enabled
                                          ? AppConstants.textPrimaryColor
                                          : Colors.grey,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                // ✅ Selected item display
                selectedItemBuilder: (BuildContext context) {
                  return TranslateLanguage.values.map<Widget>((
                    TranslateLanguage lang,
                  ) {
                    final displayName = _getShortDisplayName(lang);
                    return Container(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_hasFlag(lang)) ...[
                            Text(
                              _getFlag(lang),
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Flexible(
                            child: Text(
                              displayName,
                              style: TextStyle(
                                color:
                                    enabled
                                        ? AppConstants.textPrimaryColor
                                        : Colors.grey,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ✅ Helper methods
  String _getDisplayName(TranslateLanguage lang) {
    final info = AppConstants.languageInfo[lang.name];
    return info?['name'] ?? _capitalize(lang.name);
  }

  String _getShortDisplayName(TranslateLanguage lang) {
    final fullName = _getDisplayName(lang);
    if (fullName.length <= 8) return fullName;

    // Special short names for common languages
    switch (lang.name.toLowerCase()) {
      case 'vietnamese':
        return 'Viet';
      case 'english':
        return 'Eng';
      case 'spanish':
        return 'Spa';
      case 'french':
        return 'Fra';
      case 'german':
        return 'Ger';
      case 'chinese':
        return 'Chi';
      case 'japanese':
        return 'Jpn';
      case 'korean':
        return 'Kor';
      case 'portuguese':
        return 'Por';
      case 'italian':
        return 'Ita';
      case 'russian':
        return 'Rus';
      case 'arabic':
        return 'Ara';
      case 'hindi':
        return 'Hin';
      default:
        return fullName.length > 6 ? '${fullName.substring(0, 6)}' : fullName;
    }
  }

  bool _hasFlag(TranslateLanguage lang) {
    return AppConstants.languageInfo[lang.name]?['flag'] != null;
  }

  String _getFlag(TranslateLanguage lang) {
    return AppConstants.languageInfo[lang.name]?['flag'] ?? '';
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}

class _SwapButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _SwapButton({required this.onPressed});

  @override
  State<_SwapButton> createState() => _SwapButtonState();
}

class _SwapButtonState extends State<_SwapButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward().then((_) => _controller.reverse());
        widget.onPressed();
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _animation.value * 3.14159,
            child: Container(
              width: 32, // ✅ Even smaller
              height: 32,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.primaryColor.withOpacity(0.3),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.swap_horiz,
                color: Colors.white,
                size: 16, // ✅ Even smaller icon
              ),
            ),
          );
        },
      ),
    );
  }
}
