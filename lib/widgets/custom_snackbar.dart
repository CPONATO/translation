import 'package:flutter/material.dart';
import '../constants/constants.dart';

class CustomSnackBar {
  static void showSuccess(BuildContext context, String message) {
    _show(context, message, AppConstants.successColor, Icons.check_circle);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, AppConstants.errorColor, Icons.error);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, AppConstants.primaryColor, Icons.info);
  }

  static void _show(
    BuildContext context,
    String message,
    Color backgroundColor,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        margin: const EdgeInsets.all(AppConstants.spacing),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
