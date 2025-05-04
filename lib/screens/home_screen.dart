import 'package:flutter/material.dart';
import 'package:thirtysix_pics/screens/new_trip_screen.dart';
import 'package:thirtysix_pics/theme/theme.dart';
import 'package:thirtysix_pics/widgets/retro_button.dart';
import 'package:thirtysix_pics/widgets/vintage_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.movie_creation_outlined,
                    color: AppColors.foreground, size: 36),
                const SizedBox(height: 8),
                Text(
                  "36 Pics",
                  style: TextStyle(
                    fontFamily: AppFonts.heading,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Capture moments, not megapixels",
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppColors.foreground.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 40),

                // New Adventure Card
                VintageCard(
                  title: "New Adventure",
                  child: RetroButton(
                    text: "Load New Film",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NewTripScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Developed Rolls Card
                VintageCard(
                  title: "Developed Rolls",
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "No developed film rolls yet",
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        color: AppColors.foreground.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
