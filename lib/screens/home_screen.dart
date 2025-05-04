import 'package:flutter/material.dart';
import 'new_trip_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder trips
    final trips = [
      {'name': 'Goa 2025', 'date': 'March 12', 'count': '28'},
      {'name': 'Manali 2024', 'date': 'Jan 5', 'count': '36'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('36 Pics')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NewTripScreen()),
                );
              },
              child: const Text('+ Start New Trip'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: trips.length,
                itemBuilder: (context, index) {
                  final trip = trips[index];
                  return Card(
                    child: ListTile(
                      title: Text(trip['name']!),
                      subtitle: Text('${trip['date']} — ${trip['count']}/36 photos'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Navigate to gallery
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
