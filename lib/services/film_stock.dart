import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

enum FilmStock { classic, noir, faded70s }

extension FilmStockLook on FilmStock {
  String get label => switch (this) {
        FilmStock.classic => 'Classic',
        FilmStock.noir => 'Noir',
        FilmStock.faded70s => "Faded '70s",
      };

  List<Color> get swatch => switch (this) {
        FilmStock.classic => const [Color(0xFFE7A05A), Color(0xFFB5502E)],
        FilmStock.noir => const [Color(0xFF9A9388), Color(0xFF4C463D)],
        FilmStock.faded70s => const [Color(0xFFD9B8C9), Color(0xFF8E7CA8)],
      };

  /// 4x5 color matrix in the layout Flutter's ColorFilter.matrix expects.
  List<double> get matrix => switch (this) {
        FilmStock.classic => _identity,
        FilmStock.noir => _look(saturation: 0, contrast: 1.3),
        FilmStock.faded70s => _look(saturation: 0.62, contrast: 0.76, lift: 28, tint: const [1.1, 1.0, 0.84]),
      };
}

const _identity = <double>[
  1, 0, 0, 0, 0, //
  0, 1, 0, 0, 0,
  0, 0, 1, 0, 0,
  0, 0, 0, 1, 0,
];

List<double> _look({
  double saturation = 1,
  double contrast = 1,
  double lift = 0,
  List<double> tint = const [1, 1, 1],
}) {
  const lum = [0.2126, 0.7152, 0.0722];
  final out = <double>[];
  for (var channel = 0; channel < 3; channel++) {
    for (var source = 0; source < 3; source++) {
      final sat = lum[source] * (1 - saturation) + (channel == source ? saturation : 0);
      out.add(sat * contrast * tint[channel]);
    }
    out.add(0);
    out.add((128 * (1 - contrast) + lift) * tint[channel]);
  }
  return [...out, 0, 0, 0, 1, 0];
}

/// Applies a film stock's look to JPEG bytes. Pure so it can run in an isolate.
Uint8List bakeFilmStock(Uint8List jpeg, FilmStock stock) {
  if (stock == FilmStock.classic) return jpeg;
  final decoded = img.decodeImage(jpeg);
  if (decoded == null) return jpeg;
  final image = img.bakeOrientation(decoded);
  final m = stock.matrix;
  for (final p in image) {
    final r = p.r.toDouble(), g = p.g.toDouble(), b = p.b.toDouble();
    p.r = (m[0] * r + m[1] * g + m[2] * b + m[4]).clamp(0, 255);
    p.g = (m[5] * r + m[6] * g + m[7] * b + m[9]).clamp(0, 255);
    p.b = (m[10] * r + m[11] * g + m[12] * b + m[14]).clamp(0, 255);
  }
  return Uint8List.fromList(img.encodeJpg(image, quality: 90));
}

Uint8List _bakeJob((Uint8List, int) args) => bakeFilmStock(args.$1, FilmStock.values[args.$2]);

/// Returns a new file with [stock] baked in, or [shot] itself for Classic.
Future<File> applyFilmStock(File shot, FilmStock stock) async {
  if (stock == FilmStock.classic) return shot;
  final baked = await compute(_bakeJob, (await shot.readAsBytes(), stock.index));
  return File('${shot.path}.${stock.name}.jpg').writeAsBytes(baked);
}
