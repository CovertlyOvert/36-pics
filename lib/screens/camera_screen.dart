import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:thirtysix_pics/screens/developing_screen.dart';
import 'package:thirtysix_pics/theme/theme.dart';
import 'package:thirtysix_pics/widgets/frame_counter_dial.dart';

class CameraScreen extends StatefulWidget {
  final String tripName;
  final int initialPhotoCount;

  const CameraScreen({
    super.key,
    required this.tripName,
    this.initialPhotoCount = 0,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  late int photoCount = widget.initialPhotoCount;
  final int maxPhotos = 36;
  bool _cameraError = false;
  bool _flashOn = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      await _startController(_cameras.first);
    } catch (e) {
      debugPrint('Camera init failed: $e');
      setState(() => _cameraError = true);
    }
  }

  Future<void> _startController(CameraDescription camera) async {
    final controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    _controller = controller;
    _initializeControllerFuture = controller.initialize();
    await _initializeControllerFuture;
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null) return;
    final next = !_flashOn;
    try {
      await controller.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      setState(() => _flashOn = next);
    } catch (e) {
      debugPrint('Flash toggle failed: $e');
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;
    final oldController = _controller;
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _startController(_cameras[_cameraIndex]);
    await oldController?.dispose();
  }

  void _capture() {
    if (photoCount >= maxPhotos) return;
    setState(() => photoCount++);
    if (photoCount >= maxPhotos) {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DevelopingScreen(tripName: widget.tripName)),
        );
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
      backgroundColor: const Color(0xFF0A0807),
      body: _cameraError
          ? const Center(
              child: Text(
                'Camera not supported or failed to load.',
                style: TextStyle(color: Colors.white),
              ),
            )
          : (_initializeControllerFuture == null || !_controller!.value.isInitialized)
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraPreview(_controller!),

                    // Rule-of-thirds composition guide
                    IgnorePointer(
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _RuleOfThirdsPainter(),
                      ),
                    ),

                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.45),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                              ),
                              child: Text(
                                widget.tripName.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Courier Prime',
                                ),
                              ),
                            ),
                            FrameCounterDial(
                              current: photoCount,
                              total: maxPhotos,
                              size: 48,
                              ringColor: Colors.black.withOpacity(0.45),
                              progressColor: Colors.white,
                              textColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SafeArea(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(width: 34),
                              _GlassButton(
                                icon: _flashOn ? Icons.flash_on : Icons.flash_off,
                                onTap: _toggleFlash,
                                tooltip: 'Toggle flash',
                              ),
                              GestureDetector(
                                onTap: _capture,
                                child: Container(
                                  width: 78,
                                  height: 78,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 4),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                                      child: Center(
                                        child: Container(
                                          width: 14,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              _GlassButton(
                                icon: Icons.flip_camera_ios_outlined,
                                onTap: _flipCamera,
                                tooltip: 'Flip camera',
                              ),
                              const SizedBox(width: 34),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _GlassButton({required this.icon, required this.onTap, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.45),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Icon(icon, color: Colors.white, size: 19),
        ),
      ),
    );
  }
}

class _RuleOfThirdsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.14)
      ..strokeWidth = 1;
    final x1 = size.width / 3;
    final x2 = size.width * 2 / 3;
    final y1 = size.height / 3;
    final y2 = size.height * 2 / 3;
    canvas.drawLine(Offset(x1, 0), Offset(x1, size.height), paint);
    canvas.drawLine(Offset(x2, 0), Offset(x2, size.height), paint);
    canvas.drawLine(Offset(0, y1), Offset(size.width, y1), paint);
    canvas.drawLine(Offset(0, y2), Offset(size.width, y2), paint);
  }

  @override
  bool shouldRepaint(covariant _RuleOfThirdsPainter oldDelegate) => false;
}
