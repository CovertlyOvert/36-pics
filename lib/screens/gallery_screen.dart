import 'package:flutter/material.dart';

class GalleryScreen extends StatelessWidget {
  final List<String> photoPaths;

  const GalleryScreen({super.key, required this.photoPaths});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gallery")),
      body: photoPaths.isEmpty
          ? const Center(child: Text("No photos taken."))
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: photoPaths.length,
              itemBuilder: (context, index) {
                return Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: Text(
                      photoPaths[index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
