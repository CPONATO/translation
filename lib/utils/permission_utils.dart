import 'package:flutter/material.dart';

class PermissionUtils {
  static Future<bool> requestCameraPermission() async {
    return true;
  }

  static Future<bool> requestMicrophonePermission() async {
    return true;
  }

  static Future<bool> requestStoragePermission() async {
    return true;
  }

  static void showPermissionDeniedDialog(
    BuildContext context,
    String permissionType,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Permission Required'),
            content: Text(
              '$permissionType permission is required for this feature. '
              'Please grant permission in your device settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Settings'),
              ),
            ],
          ),
    );
  }
}
