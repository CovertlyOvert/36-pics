import 'dart:async';
import 'package:flutter/material.dart';
import 'package:thirtysix_pics/screens/gallery_screen.dart';
import 'package:thirtysix_pics/services/roll_store.dart';
import 'package:thirtysix_pics/theme/theme.dart';

/// Shown while a finished roll develops. The wait is wall-clock based
/// (roll.developAt), so it keeps counting while the app is closed.
class DevelopingScreen extends StatefulWidget {
  final String rollId;

  const DevelopingScreen({super.key, required this.rollId});

  @override
  State<DevelopingScreen> createState() => _DevelopingScreenState();
}

class _DevelopingScreenState extends State<DevelopingScreen> {
  Timer? _timer;

  Roll get _roll => RollStore.instance.roll(widget.rollId)!;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      if (_roll.isDeveloped) _timer?.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roll = _roll;
    final isReady = roll.isDeveloped;
    final progress = isReady ? 1.0 : roll.developProgress;
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
                          value: progress,
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
                  'ROLL · ${roll.name.toUpperCase()}',
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
                  '${roll.photos.length} exposures',
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
                          value: progress,
                          minHeight: 4,
                          backgroundColor: Colors.white.withOpacity(0.12),
                          valueColor: AlwaysStoppedAnimation(AppColors.secondary),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isReady ? 'READY TO VIEW' : 'READY IN ${formatRemaining(roll.timeRemaining).toUpperCase()}',
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
                SizedBox(
                  width: double.infinity,
                  child: isReady
                      ? ElevatedButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => GalleryScreen(rollId: roll.id)),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryForeground,
                            foregroundColor: AppColors.primaryDeep,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text('View Developed Roll', style: TextStyle(fontWeight: FontWeight.w600)),
                        )
                      : TextButton(
                          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                          style: TextButton.styleFrom(foregroundColor: AppColors.primaryForeground),
                          child: const Text('Back to Library'),
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
