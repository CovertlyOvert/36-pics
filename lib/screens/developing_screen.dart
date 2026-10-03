import 'dart:async';
import 'package:flutter/material.dart';
import 'package:thirtysix_pics/screens/gallery_screen.dart';
import 'package:thirtysix_pics/theme/theme.dart';

/// Shown right after a roll's 36th exposure. Real film takes time to
/// develop; we simulate a short version of that wait rather than
/// revealing the shots instantly, so finishing a roll still feels like
/// an event.
class DevelopingScreen extends StatefulWidget {
  final String tripName;

  const DevelopingScreen({super.key, required this.tripName});

  @override
  State<DevelopingScreen> createState() => _DevelopingScreenState();
}

class _DevelopingScreenState extends State<DevelopingScreen> {
  static const _developDuration = Duration(seconds: 4);
  double _progress = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    const tick = Duration(milliseconds: 80);
    final steps = _developDuration.inMilliseconds / tick.inMilliseconds;
    _timer = Timer.periodic(tick, (timer) {
      setState(() => _progress = (_progress + 1 / steps).clamp(0.0, 1.0));
      if (_progress >= 1.0) timer.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReady = _progress >= 1.0;
    return Scaffold(
      backgroundColor: AppColors.primaryDeep,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.3),
            radius: 1.0,
            colors: [AppColors.primary.withOpacity(0.55), AppColors.primaryDeep],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: CircularProgressIndicator(
                          value: _progress,
                          strokeWidth: 2.5,
                          backgroundColor: Colors.white.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation(AppColors.secondary),
                        ),
                      ),
                      Icon(Icons.camera_roll_outlined, color: AppColors.primaryForeground, size: 28),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'ROLL · ${widget.tripName.toUpperCase()}',
                  style: TextStyle(
                    fontFamily: AppFonts.mono,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isReady ? 'Your roll is\nready' : 'Your roll is\ndeveloping',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.heading,
                    fontWeight: FontWeight.w600,
                    fontSize: 27,
                    height: 1.25,
                    color: AppColors.primaryForeground,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '36 exposures',
                  style: TextStyle(fontSize: 13.5, color: AppColors.primaryForeground.withOpacity(0.75)),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 220,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: _progress,
                          minHeight: 4,
                          backgroundColor: Colors.white.withOpacity(0.12),
                          valueColor: AlwaysStoppedAnimation(AppColors.secondary),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isReady ? 'READY TO VIEW' : "WE'LL NOTIFY YOU WHEN READY",
                        style: TextStyle(
                          fontFamily: AppFonts.mono,
                          fontSize: 10,
                          letterSpacing: 1,
                          color: AppColors.primaryForeground.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                AnimatedOpacity(
                  opacity: isReady ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isReady
                          ? () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GalleryScreen(
                                    tripName: widget.tripName,
                                    dateLabel: 'TODAY',
                                    photoCount: 36,
                                  ),
                                ),
                              )
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryForeground,
                        foregroundColor: AppColors.primaryDeep,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('View Developed Roll', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
