import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  final String tripName;

  const CameraScreen({super.key, required this.tripName});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _cameraError = false;

  int photoCount = 0;
  final int maxPhotos = 36;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      if (Platform.isIOS && !Platform.isMacOS) {
        final cameras = await availableCameras();
        final camera = cameras.first;

        _controller = CameraController(camera, ResolutionPreset.medium);
        _initializeControllerFuture = _controller!.initialize();
      } else {
        _initializeControllerFuture = Future.value();
      }
    } catch (e) {
      debugPrint('Camera init failed: $e');
      _cameraError = true;
      _initializeControllerFuture = Future.value();
    }

    if (mounted) setState(() {});
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
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (_cameraError || snapshot.hasError) {
            return _mockViewfinder(message: 'Camera not supported or failed to load.');
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                _controller != null
                    ? CameraPreview(_controller!)
                    : _mockViewfinder(),
                _sepiaGrainOverlay(),
                _crosshairOverlay(),
                _topBar(),
                _shutterButton(),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
        },
      ),
    );
  }

  Widget _mockViewfinder({String message = 'Camera Preview (Mocked)'}) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/mock_viewfinder.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  Widget _sepiaGrainOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.2),
      foregroundDecoration: const BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Color.fromRGBO(112, 66, 20, 0.1),
            Colors.transparent,
          ],
          radius: 0.8,
        ),
      ),
    );
  }

  Widget _crosshairOverlay() {
    return Center(
      child: Image.asset(
        'assets/overlays/crosshair.webp',
        width: 60,
        height: 60,
        color: Colors.white70,
      ),
    );
  }

  Widget _topBar() {
    return Positioned(
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
              fontFamily: 'Courier Prime',
            ),
          ),
          Text(
            '$photoCount/36',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Courier Prime',
            ),
          ),
        ],
      ),
    );
  }

  Widget _shutterButton() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Center(
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
    );
  }
}
