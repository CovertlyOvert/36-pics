import 'package:flutter/material.dart';
import '../theme/theme.dart';

class PolaroidCard extends StatelessWidget {
  final String title;
  final Widget child;

  const PolaroidCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 32), // bottom heavy
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontFamily: 'PlayfairDisplay',
                    fontWeight: FontWeight.bold,
                    color: AppColors.cardForeground,
                  ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
