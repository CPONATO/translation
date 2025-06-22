import 'package:flutter/material.dart';
import '../constants/constants.dart';

class ErrorBoundary extends StatelessWidget {
  final Widget child;
  final Widget? errorWidget;
  final String? errorMessage;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorWidget,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }

  static Widget defaultErrorWidget(String? message) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacing),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppConstants.errorColor),
          const SizedBox(height: AppConstants.spacing),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppConstants.smallSpacing),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
