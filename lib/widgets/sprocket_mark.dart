import 'dart:math' as math;
import 'package:flutter/material.dart';

/// The brand mark: eight film sprocket holes in a ring, squares at the
/// compass points and diamonds between them.
class SprocketMark extends StatelessWidget {
  final double size;
  final Color color;

  const SprocketMark({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size(size, size), painter: _SprocketPainter(color));
}

class _SprocketPainter extends CustomPainter {
  final Color color;

  _SprocketPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final ring = size.width * 0.36;
    final half = size.width * 0.095;
    final paint = Paint()..color = color;
    for (var i = 0; i < 8; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * math.pi / 4);
      canvas.translate(0, -ring);
      if (i.isOdd) canvas.rotate(math.pi / 4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: half * 2, height: half * 2), Radius.circular(half * 0.3)),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SprocketPainter old) => old.color != color;
}
