// lib/widgets/language_selector.dart
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
      padding: const EdgeInsets.all(AppConstants.spacing),
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
      child: Row(
        children: [
          Expanded(
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

          const SizedBox(width: AppConstants.smallSpacing),

          _SwapButton(onPressed: onSwapLanguages),

          const SizedBox(width: AppConstants.smallSpacing),

          Expanded(
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
    );
  }
}

class _LanguageDropdown extends StatelessWidget {
  final TranslateLanguage language;
  final Function(TranslateLanguage?) onChanged; // FIX: Thêm nullable type
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppConstants.fontSizeSmall,
            color: AppConstants.textSecondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  enabled
                      ? AppConstants.primaryColor.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(8),
            color: enabled ? Colors.white : Colors.grey.shade100,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<TranslateLanguage>(
              value: language,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: enabled ? AppConstants.primaryColor : Colors.grey,
              ),
              onChanged: enabled ? onChanged : null, // FIX: Đã có nullable type
              items:
                  TranslateLanguage.values.map((lang) {
                    final info = AppConstants.languageInfo[lang.name];
                    return DropdownMenuItem<TranslateLanguage>(
                      value: lang,
                      child: Row(
                        children: [
                          if (info?['flag'] != null) ...[
                            Text(
                              info!['flag']!,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              info?['name'] ?? lang.name.toUpperCase(),
                              style: TextStyle(
                                color:
                                    enabled
                                        ? AppConstants.textPrimaryColor
                                        : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
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
      duration: AppConstants.mediumAnimation,
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
        _controller.forward().then((_) {
          _controller.reverse();
        });
        widget.onPressed();
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _animation.value * 3.14159, // 180 degrees
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.primaryColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.swap_horiz,
                color: Colors.white,
                size: 20,
              ),
            ),
          );
        },
      ),
    );
  }
}
