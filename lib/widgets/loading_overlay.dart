import 'package:flutter/material.dart';
import '../constants/constants.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final double progress;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.progress = 0.0,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: _LoadingIndicator(progress: progress, message: message),
            ),
          ),
      ],
    );
  }
}

class _LoadingIndicator extends StatefulWidget {
  final double progress;
  final String? message;

  const _LoadingIndicator({required this.progress, this.message});

  @override
  State<_LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<_LoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(AppConstants.largeSpacing),
          decoration: BoxDecoration(
            color: AppConstants.cardColor,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: widget.progress > 0 ? widget.progress : null,
                      strokeWidth: 4,
                      backgroundColor: AppConstants.primaryColor.withOpacity(
                        0.2,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppConstants.primaryColor,
                      ),
                    ),
                    if (widget.progress > 0)
                      Center(
                        child: Text(
                          '${(widget.progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: AppConstants.fontSizeSmall,
                            fontWeight: FontWeight.w600,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacing),
              Text(
                widget.message ?? 'Loading...',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.w500,
                  color: AppConstants.textPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
