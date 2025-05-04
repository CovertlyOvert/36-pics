import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/trip.dart';
import 'camera_screen.dart';
import '../theme/theme.dart';
import '../widgets/retro_button.dart';
import '../widgets/polaroid_card.dart';

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
        title: const Text(
          'New Trip',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: PolaroidCard(
          title: 'Name Your Trip',
          child: Column(
            children: [
              TextField(
                controller: _tripNameController,
                decoration: const InputDecoration(
                  labelText: 'Trip Name',
                  labelStyle: TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.foreground,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              RetroButton(
                text: 'Start Trip',
                onPressed: _startTrip,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
