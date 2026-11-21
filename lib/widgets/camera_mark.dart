import 'package:flutter/material.dart';

/// The brand mark: a compact film camera, drawn as one solid shape with the
/// flash window, viewfinder and lens cut out. Matches the app icon.
class CameraMark extends StatelessWidget {
  final double size;
  final Color color;

  const CameraMark({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _CameraPainter(color));
}

class _CameraPainter extends CustomPainter {
  final Color color;

  _CameraPainter(this.color);

  // Drawn in a 724 x 480 box (the icon's camera, shutter button to base).
  static const _w = 724.0;
  static const _h = 480.0;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / _w;
    canvas.save();
    canvas.translate(0, (size.height - _h * scale) / 2);
    canvas.scale(scale);

    RRect rr(double l, double t, double r, double b, double radius) =>
        RRect.fromLTRBR(l, t, r, b, Radius.circular(radius));

    final silhouette = Path.combine(
      PathOperation.union,
      Path()..addRRect(rr(0, 34, 724, 480, 76)),
      Path()..addRRect(rr(526, 0, 632, 44, 18)),
    )..fillType = PathFillType.evenOdd;

    silhouette
      ..addRRect(rr(64, 78, 222, 150, 16)) // flash window
      ..addRRect(rr(260, 78, 360, 132, 14)) // viewfinder
      ..addOval(Rect.fromCircle(center: const Offset(362, 276), radius: 178)) // lens ring gap
      ..addOval(Rect.fromCircle(center: const Offset(362, 276), radius: 122)) // lens barrel
      ..addOval(Rect.fromCircle(center: const Offset(362, 276), radius: 52)); // glass

    canvas.drawPath(silhouette, Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CameraPainter old) => old.color != color;
}
