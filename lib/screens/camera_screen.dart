import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';

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
  bool _cameraError = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.first;
      _controller = CameraController(camera, ResolutionPreset.medium);
      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Camera init failed: $e');
      setState(() {
        _cameraError = true;
      });
    }
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
      body: _cameraError
          ? const Center(
              child: Text(
                'Camera not supported or failed to load.',
                style: TextStyle(color: Colors.white),
              ),
            )
          : (_initializeControllerFuture == null || !_controller!.value.isInitialized)
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    CameraPreview(_controller!),

                    // Crosshair overlay
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Center(
                          child: Image.asset(
                            'assets/overlays/crosshair.webp',
                            width: 150,
                            height: 150,
                            fit: BoxFit.contain,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),

                    // Trip name and counter
                    Positioned(
                      top: 60,
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
                              fontFamily: 'Courier Prime',
                            ),
                          ),
                          Text(
                            '$photoCount/$maxPhotos',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'Courier Prime',
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Capture button
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            // Simulate photo capture
                            if (photoCount < maxPhotos) {
                              setState(() => photoCount++);
                            }
                          },
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: const Center(
                              child: Icon(Icons.camera_alt, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
