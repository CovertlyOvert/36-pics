import 'package:flutter/material.dart';
import 'package:thirtysix_pics/models/trip.dart';
import 'package:thirtysix_pics/screens/camera_screen.dart';
import 'package:thirtysix_pics/theme/theme.dart';
import 'package:uuid/uuid.dart';

class NewTripScreen extends StatefulWidget {
  const NewTripScreen({super.key});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  final TextEditingController _tripNameController = TextEditingController();

  void _startTrip() {
    if (_tripNameController.text.trim().isEmpty) return;

    final newTrip = Trip(
      id: const Uuid().v4(),
      name: _tripNameController.text.trim(),
      createdAt: DateTime.now(),
      photoPaths: [],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(tripName: newTrip.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("New Trip"),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.foreground,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
        child: Column(
          children: [
            // Hero animation for icon
            Hero(
              tag: 'film-roll',
              child: Icon(Icons.movie_creation_outlined,
                  color: AppColors.primary, size: 48),
            ),
            const SizedBox(height: 24),

            Text(
              "Name Your Roll",
              style: TextStyle(
                fontFamily: AppFonts.heading,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _tripNameController,
              decoration: InputDecoration(
                labelText: "Trip Name",
                labelStyle: TextStyle(
                  fontFamily: AppFonts.body,
                  color: AppColors.foreground.withOpacity(0.7),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
              style: TextStyle(
                fontFamily: AppFonts.body,
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _startTrip,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              icon: const Icon(Icons.camera_alt),
              label: Text(
                "Start Shooting",
                style: TextStyle(
                  fontFamily: AppFonts.mono,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
