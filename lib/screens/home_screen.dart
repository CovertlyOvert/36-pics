import 'package:flutter/material.dart';
import 'package:thirtysix_pics/screens/new_trip_screen.dart';
import 'package:thirtysix_pics/theme/theme.dart';
import 'package:thirtysix_pics/widgets/retro_button.dart';
import 'package:thirtysix_pics/widgets/vintage_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy developed trips
    final trips = [
      {'name': 'Goa 2025', 'date': 'March 12', 'count': '28'},
      {'name': 'Manali 2024', 'date': 'Jan 5', 'count': '36'},
      {'name': 'Kerala Backwaters', 'date': 'Dec 15', 'count': '21'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'film-roll',
                  child: Icon(Icons.movie_creation_outlined,
                    color: AppColors.foreground, size: 36),
                ),
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

                // Developed Rolls List
                VintageCard(
                  title: "Developed Rolls",
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: trips.length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: AppColors.border),
                    itemBuilder: (context, index) {
                      final trip = trips[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          trip['name']!,
                          style: TextStyle(
                            fontFamily: AppFonts.heading,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: AppColors.foreground,
                          ),
                        ),
                        subtitle: Text(
                          "${trip['date']} — ${trip['count']}/36 photos",
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 14,
                            color: AppColors.foreground.withOpacity(0.7),
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            size: 16, color: AppColors.foreground),
                        onTap: () {
                          // TODO: Navigate to gallery view
                        },
                      );
                    },
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
