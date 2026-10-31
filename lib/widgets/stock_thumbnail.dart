import 'package:flutter/material.dart';
import 'package:thirtysix_pics/services/film_stock.dart';

/// A small sample scene rendered through a stock's real colour matrix, so the
/// look can be judged before committing to it.
class StockThumbnail extends StatelessWidget {
  final FilmStock stock;

  const StockThumbnail({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final scene = CustomPaint(painter: _ScenePainter(), size: Size.infinite);
    if (stock == FilmStock.classic) return scene;
    return ColorFiltered(colorFilter: ColorFilter.matrix(stock.matrix), child: scene);
  }
}

class _ScenePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF5E9BC9), Color(0xFFF2C58A)],
        ).createShader(rect),
    );
    canvas.drawCircle(Offset(size.width * 0.74, size.height * 0.3), size.width * 0.11, Paint()..color = const Color(0xFFF7D96B));
    final hills = Path()
      ..moveTo(0, size.height * 0.72)
      ..lineTo(size.width * 0.32, size.height * 0.42)
      ..lineTo(size.width * 0.62, size.height * 0.7)
      ..lineTo(size.width * 0.8, size.height * 0.55)
      ..lineTo(size.width, size.height * 0.72)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hills, Paint()..color = const Color(0xFF3F8F5B));
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.84, size.width, size.height * 0.16), Paint()..color = const Color(0xFFC1472B));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
