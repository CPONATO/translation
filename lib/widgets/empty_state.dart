import 'package:flutter/material.dart';
import '../constants/constants.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largeSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppConstants.textSecondaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: AppConstants.spacing),
            Text(
              title,
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.w600,
                color: AppConstants.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppConstants.smallSpacing),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  color: AppConstants.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppConstants.spacing),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
