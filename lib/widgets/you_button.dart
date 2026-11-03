import 'package:flutter/material.dart';
import 'package:thirtysix_pics/screens/you_screen.dart';
import 'package:thirtysix_pics/theme/theme.dart';

/// Opens the You screen (theme and develop time) from a tab header.
class YouButton extends StatelessWidget {
  const YouButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'You',
      onPressed:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const YouScreen()),
          ),
      icon: Icon(Icons.person_outline, color: AppColors.primary, size: 22),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.card,
        side: BorderSide(color: AppColors.border),
        minimumSize: const Size(40, 40),
      ),
    );
  }
}
