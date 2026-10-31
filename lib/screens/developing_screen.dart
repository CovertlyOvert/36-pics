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
    final (big, small) = countdownParts(roll.timeRemaining);
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
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ROLL · ${roll.name.toUpperCase()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.mono,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 232,
                  height: 232,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 232,
                        height: 232,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          strokeCap: StrokeCap.round,
                          backgroundColor: Colors.white.withOpacity(0.16),
                          valueColor: AlwaysStoppedAnimation(AppColors.primaryForeground),
                        ),
                      ),
                      if (isReady)
                        Icon(Icons.check_rounded, color: AppColors.primaryForeground, size: 84)
                      else
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              big,
                              style: TextStyle(
                                fontFamily: AppFonts.heading,
                                fontWeight: FontWeight.bold,
                                fontSize: 60,
                                height: 1,
                                color: AppColors.primaryForeground,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              small,
                              style: TextStyle(
                                fontFamily: AppFonts.mono,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.primaryForeground,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'UNTIL READY',
                              style: TextStyle(
                                fontFamily: AppFonts.mono,
                                fontSize: 10,
                                letterSpacing: 1.5,
                                color: AppColors.primaryForeground.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  isReady ? 'Your roll is ready' : 'Your roll is developing',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppFonts.heading,
                    fontWeight: FontWeight.w600,
                    fontSize: 26,
                    color: AppColors.primaryForeground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isReady
                      ? '${roll.photos.length} exposures'
                      : '${roll.photos.length} exposures · ready ${readyOnLabel(roll.developAt!)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.primaryForeground.withOpacity(0.85)),
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
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryForeground,
                            minimumSize: const Size.fromHeight(48),
                          ),
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
