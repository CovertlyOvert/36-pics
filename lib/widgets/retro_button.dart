import 'package:flutter/material.dart';
import '../theme/theme.dart';

class RetroButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const RetroButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,          // Brown
        foregroundColor: AppColors.primaryForeground, // Light cream text
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: AppColors.primary),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Courier Prime',
          fontWeight: FontWeight.bold,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
        elevation: 4,
      ),
      child: Text(text),
    );
  }
}
