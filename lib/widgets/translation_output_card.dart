import 'package:flutter/material.dart';
import '../constants/constants.dart';

class TranslationOutputCard extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onCopy;
  final VoidCallback onSpeak;

  const TranslationOutputCard({
    super.key,
    required this.text,
    required this.isLoading,
    required this.onCopy,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacing),
            child: Row(
              children: [
                Icon(
                  Icons.translate,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Translation',
                  style: TextStyle(
                    color: AppConstants.textSecondaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: AppConstants.fontSizeSmall,
                  ),
                ),
                const Spacer(),

                if (text.isNotEmpty) ...[
                  _ActionButton(
                    icon: Icons.copy,
                    onPressed: onCopy,
                    tooltip: 'Copy',
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.volume_up,
                    onPressed: onSpeak,
                    tooltip: 'Speak',
                  ),
                ],
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacing),
              child:
                  isLoading
                      ? _LoadingWidget()
                      : text.isEmpty
                      ? _EmptyStateWidget()
                      : _TranslationText(text: text),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppConstants.primaryColor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppConstants.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Translating...',
            style: TextStyle(
              color: AppConstants.textSecondaryColor,
              fontSize: AppConstants.fontSizeSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.translate_outlined,
            size: 48,
            color: AppConstants.textSecondaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Translation will appear here',
            style: TextStyle(
              color: AppConstants.textSecondaryColor,
              fontSize: AppConstants.fontSizeSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _TranslationText extends StatelessWidget {
  final String text;

  const _TranslationText({required this.text});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SelectableText(
        text,
        style: const TextStyle(
          fontSize: AppConstants.fontSizeMedium,
          height: 1.5,
          color: AppConstants.textPrimaryColor,
        ),
      ),
    );
  }
}
