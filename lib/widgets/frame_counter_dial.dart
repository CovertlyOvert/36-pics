import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A circular exposure-count dial, styled after a mechanical camera's
/// frame counter — used wherever we show "N of 36" in the redesign.
class FrameCounterDial extends StatelessWidget {
  final int current;
  final int total;
  final double size;
  final Color ringColor;
  final Color progressColor;
  final Color textColor;

  const FrameCounterDial({
    super.key,
    required this.current,
    required this.total,
    required this.ringColor,
    required this.progressColor,
    required this.textColor,
    this.size = 76,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : (current / total).clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DialPainter(
              progress: progress,
              ringColor: ringColor,
              progressColor: progressColor,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$current',
                style: TextStyle(
                  fontFamily: 'Courier Prime',
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.26,
                  color: textColor,
                  height: 1,
                ),
              ),
              Text(
                'OF $total',
                style: TextStyle(
                  fontFamily: 'Courier Prime',
                  fontSize: size * 0.105,
                  letterSpacing: 1,
                  color: textColor.withOpacity(0.75),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final Color progressColor;

  _DialPainter({
    required this.progress,
    required this.ringColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.09;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = ringColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.ringColor != ringColor ||
      oldDelegate.progressColor != progressColor;
}
