import 'package:flutter/material.dart';

class UIHelpers {
  static void showToast({
    required BuildContext context,
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        duration: duration,
      ),
    );
  }

  static String cleanErrorMessage(String errorMessage) {
    // Clean up the error message by removing "Exception: " prefix
    if (errorMessage.startsWith('Exception: ')) {
      return errorMessage.substring('Exception: '.length);
    }
    return errorMessage;
  }
}
