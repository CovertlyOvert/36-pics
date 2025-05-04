import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'gallery_screen.dart';

class CameraScreen extends StatefulWidget {
  final String tripName;

  const CameraScreen({super.key, required this.tripName});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  int photoCount = 0;
  final int maxPhotos = 36;
  List<String> photoPaths = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (Platform.isIOS && !Platform.isMacOS) {
      try {
        final cameras = await availableCameras();
        final camera = cameras.first;

        _controller = CameraController(camera, ResolutionPreset.medium);
        _initializeControllerFuture = _controller!.initialize();
      } catch (e) {
        debugPrint('Camera init failed: $e');
        _initializeControllerFuture = Future.value(); // fallback
      }
    } else {
      _initializeControllerFuture = Future.value(); // simulator fallback
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _mockCapture() {
    if (photoCount >= maxPhotos) return;

    setState(() {
      photoCount += 1;
      photoPaths.add('mock_photo_$photoCount.jpg');
    });

    debugPrint("📸 Mock photo taken! Saved as mock_photo_$photoCount.jpg");
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _initializeControllerFuture == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: [
                      // Mock camera preview
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.grey[900],
                        child: const Center(
                          child: Text(
                            'Camera Preview (Mocked)',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                      // Trip name and photo count
                      Positioned(
                        top: 50,
                        left: 20,
                        right: 20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.tripName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Courier',
                              ),
                            ),
                            Text(
                              '$photoCount/$maxPhotos',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Courier',
                              ),
                            ),
                          ],
                        ),
                      ),
                      // View Gallery Button
                      Positioned(
                        bottom: 100,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GalleryScreen(photoPaths: photoPaths),
                                ),
                              );
                            },
                            child: const Text("View Gallery"),
                          ),
                        ),
                      ),
                      // Capture button
                      Positioned(
                        bottom: 40,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: photoCount < maxPhotos ? _mockCapture : null,
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: photoCount < maxPhotos ? Colors.white : Colors.grey,
                                  width: 4,
                                ),
                              ),
                              child: const Center(
                                child: Icon(Icons.camera_alt, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
    );
  }
}
