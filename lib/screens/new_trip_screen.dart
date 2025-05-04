import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/trip.dart';
import 'camera_screen.dart';

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

    // Navigate to camera screen
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
      appBar: AppBar(title: const Text('Start New Trip')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _tripNameController,
              decoration: const InputDecoration(labelText: 'Trip Name'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startTrip,
              child: const Text('Start Trip'),
            ),
          ],
        ),
      ),
    );
  }
}
