import 'package:flutter/material.dart';
import '../constants/constants.dart';

class AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final bool expands;
  final Function(String)? onChanged;
  final VoidCallback? onTap;

  const AnimatedTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.expands = false,
    this.onChanged,
    this.onTap,
  });

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _borderColorAnimation;
  late Animation<double> _labelScaleAnimation;

  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppConstants.shortAnimation,
      vsync: this,
    );

    _borderColorAnimation = ColorTween(
      begin: Colors.grey.shade300,
      end: AppConstants.primaryColor,
    ).animate(_controller);

    _labelScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(_controller);

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });

      if (_isFocused) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(
              color: _borderColorAnimation.value ?? Colors.grey.shade300,
              width: _isFocused ? 2 : 1,
            ),
            color: AppConstants.cardColor,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            maxLines: widget.maxLines,
            expands: widget.expands,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            textAlignVertical: widget.expands ? TextAlignVertical.top : null,
            style: const TextStyle(
              fontSize: AppConstants.fontSizeMedium,
              color: AppConstants.textPrimaryColor,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              labelText: widget.labelText,
              prefixIcon:
                  widget.prefixIcon != null
                      ? Icon(
                        widget.prefixIcon,
                        color:
                            _isFocused
                                ? AppConstants.primaryColor
                                : AppConstants.textSecondaryColor,
                      )
                      : null,
              suffixIcon: widget.suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppConstants.spacing),
              hintStyle: TextStyle(
                color: AppConstants.textSecondaryColor,
                fontSize: AppConstants.fontSizeMedium,
              ),
              labelStyle: TextStyle(
                color:
                    _isFocused
                        ? AppConstants.primaryColor
                        : AppConstants.textSecondaryColor,
              ),
            ),
          ),
        );
      },
    );
  }
}
