import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:thirtysix_pics/screens/developing_screen.dart';
import 'package:thirtysix_pics/services/film_stock.dart';
import 'package:thirtysix_pics/services/roll_store.dart';
import 'package:thirtysix_pics/theme/theme.dart';
import 'package:thirtysix_pics/widgets/frame_counter_dial.dart';

class CameraScreen extends StatefulWidget {
  final String rollId;

  const CameraScreen({super.key, required this.rollId});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  Roll get _roll => RollStore.instance.roll(widget.rollId)!;
  int get photoCount => _roll.photos.length;
  final int maxPhotos = rollSize;
  bool _cameraError = false;
  bool _flashOn = false;
  bool _capturing = false;
  bool _switching = false;
  bool _shutterFlash = false;
  Offset? _focusPoint;
  double _minZoom = 1;
  double _maxZoom = 1;
  double _zoom = 1;
  double _baseZoom = 1;

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
    final old = _controller;
    if (old != null) {
      // Tear the old session down (and its preview out of the tree) before
      // opening the next one; iOS can't run two capture sessions at once.
      setState(() {
        _controller = null;
        _initializeControllerFuture = null;
      });
      await WidgetsBinding.instance.endOfFrame;
      await old.dispose();
    }
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _controller = controller;
    _initializeControllerFuture = controller.initialize();
    await _initializeControllerFuture;
    _minZoom = await controller.getMinZoomLevel();
    _maxZoom = (await controller.getMaxZoomLevel()).clamp(_minZoom, 8.0);
    _zoom = _minZoom;
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _focusAt(Offset position, Size size) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final point = Offset(position.dx / size.width, position.dy / size.height);
    setState(() => _focusPoint = position);
    try {
      await controller.setFocusPoint(point);
      await controller.setExposurePoint(point);
    } catch (e) {
      debugPrint('Focus failed: $e');
    }
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _focusPoint = null);
    });
  }

  void _setZoom(double value) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    _zoom = value.clamp(_minZoom, _maxZoom);
    controller.setZoomLevel(_zoom);
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
    if (_cameras.length < 2 || _switching) return;
    final current = _cameras[_cameraIndex].lensDirection;
    final next = _cameras.indexWhere((c) => c.lensDirection != current);
    if (next == -1) return;
    _switching = true;
    _cameraIndex = next;
    _flashOn = false;
    try {
      await _startController(_cameras[_cameraIndex]);
    } catch (e) {
      debugPrint('Flip camera failed: $e');
      if (mounted) setState(() => _cameraError = true);
    } finally {
      _switching = false;
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (_capturing ||
        photoCount >= maxPhotos ||
        controller == null ||
        !controller.value.isInitialized) {
      return;
    }
    final stock = _roll.stock;
    setState(() {
      _capturing = true;
      _shutterFlash = true;
    });
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _shutterFlash = false);
    });
    try {
      final shot = await controller.takePicture();
      final styled = await applyFilmStock(File(shot.path), stock);
      final saved = await RollStore.instance.addPhoto(
        widget.rollId,
        styled,
        stock: stock,
      );
      if (!mounted) return;
      if (!saved) {
        _showError('Could not save photo');
      } else {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Capture failed: $e');
      _showError('Capture failed');
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
    if (mounted && photoCount >= maxPhotos) {
      await RollStore.instance.finishRoll(widget.rollId);
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DevelopingScreen(rollId: widget.rollId),
        ),
      );
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
      body:
          _cameraError
              ? const Center(
                child: Text(
                  'Camera not supported or failed to load.',
                  style: TextStyle(color: Colors.white),
                ),
              )
              : (_initializeControllerFuture == null ||
                  !_controller!.value.isInitialized)
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
              : Stack(
                fit: StackFit.expand,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final preview = _controller!.value.previewSize!;
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown:
                            (d) =>
                                _focusAt(d.localPosition, constraints.biggest),
                        onScaleStart: (_) => _baseZoom = _zoom,
                        onScaleUpdate: (d) => _setZoom(_baseZoom * d.scale),
                        child: ClipRect(
                          child: SizedBox.expand(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: preview.height,
                                height: preview.width,
                                child:
                                    _roll.stock == FilmStock.classic
                                        ? CameraPreview(_controller!)
                                        : ColorFiltered(
                                          colorFilter: ColorFilter.matrix(
                                            _roll.stock.matrix,
                                          ),
                                          child: CameraPreview(_controller!),
                                        ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  if (_focusPoint != null)
                    Positioned(
                      left: _focusPoint!.dx - 32,
                      top: _focusPoint!.dy - 32,
                      child: IgnorePointer(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.amber, width: 1.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),

                  IgnorePointer(
                    child: AnimatedOpacity(
                      opacity: _shutterFlash ? 0.7 : 0,
                      duration: const Duration(milliseconds: 80),
                      child: Container(color: Colors.white),
                    ),
                  ),

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
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _StockSwitcher(
                              current: _roll.stock,
                              onChanged: (stock) async {
                                await RollStore.instance.setStock(
                                  widget.rollId,
                                  stock,
                                );
                                if (mounted) setState(() {});
                              },
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(width: 34),
                                _GlassButton(
                                  icon:
                                      _flashOn
                                          ? Icons.flash_on
                                          : Icons.flash_off,
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
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      ),
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
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

class _StockSwitcher extends StatelessWidget {
  final FilmStock current;
  final ValueChanged<FilmStock> onChanged;

  const _StockSwitcher({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final stock in FilmStock.values)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(stock),
              child: Container(
                constraints: const BoxConstraints(minHeight: 36, minWidth: 64),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: stock == current ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  stock.label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: stock == current ? Colors.black : Colors.white,
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

  const _GlassButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

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
    final paint =
        Paint()
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
