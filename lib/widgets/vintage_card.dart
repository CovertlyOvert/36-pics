import 'package:flutter/material.dart';
import 'package:thirtysix_pics/theme/theme.dart';

class VintageCard extends StatelessWidget {
  final String title;
  final Widget child;

  const VintageCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.muted,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: AppFonts.heading,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 60,
            height: 2,
            color: AppColors.border,
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
