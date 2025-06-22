import 'package:flutter/material.dart';
import '../constants/constants.dart';

class TranslationInputCard extends StatelessWidget {
  final TextEditingController controller;
  final bool isListening;
  final VoidCallback onClear;

  const TranslationInputCard({
    super.key,
    required this.controller,
    required this.isListening,
    required this.onClear,
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
                  Icons.edit_note,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Enter text to translate',
                  style: TextStyle(
                    color: AppConstants.textSecondaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: AppConstants.fontSizeSmall,
                  ),
                ),
                const Spacer(),
                if (controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: onClear,
                    child: Icon(
                      Icons.clear,
                      color: AppConstants.textSecondaryColor,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppConstants.spacing),
                  child: TextField(
                    controller: controller,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeMedium,
                      height: 1.5,
                    ),
                    decoration: const InputDecoration(
                      hintText: "Start typing, speaking, or take a photo...",
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: AppConstants.textSecondaryColor,
                        fontSize: AppConstants.fontSizeMedium,
                      ),
                    ),
                  ),
                ),

                if (isListening)
                  Positioned(
                    bottom: AppConstants.spacing,
                    right: AppConstants.spacing,
                    child: _ListeningIndicator(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListeningIndicator extends StatefulWidget {
  @override
  State<_ListeningIndicator> createState() => _ListeningIndicatorState();
}

class _ListeningIndicatorState extends State<_ListeningIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppConstants.errorColor.withOpacity(_animation.value),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.mic, color: Colors.white, size: 20),
        );
      },
    );
  }
}
