import 'package:flutter/material.dart';

class SnackBarService {
  BuildContext? _buildContext;

  static SnackBarService instance = SnackBarService();

  SnackBarService();

  set buildContext(BuildContext context) {
    _buildContext = context;
  }

  void showSnackBar(String message, bool success) {
    ScaffoldMessenger.of(_buildContext!).showSnackBar(
      SnackBar(
          duration: const Duration(seconds: 3),
          content: Text(
            message,
            style: const TextStyle(
              color: Color(0xFF461959),
              fontSize: 15,
            ),
          ),
          backgroundColor:
              success ? const Color(0xFFCBFFA9) : const Color(0xFFFF9B9B)),
    );
  }
}
