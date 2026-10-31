import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thirtysix_pics/services/film_stock.dart';
import 'package:thirtysix_pics/theme/theme.dart';
import 'package:uuid/uuid.dart';

class DevelopDelay {
  final String label;
  final Duration duration;
  final String caption;

  const DevelopDelay(this.label, this.duration, this.caption);
}

const developDelayOptions = [
  DevelopDelay('15 seconds', Duration(seconds: 15), 'Instant gratification. No waiting.'),
  DevelopDelay('1 hour', Duration(hours: 1), 'A coffee break between shot and reveal.'),
  DevelopDelay('6 hours', Duration(hours: 6), 'Shoot in the morning, see it by night.'),
  DevelopDelay('1 day', Duration(days: 1), 'Overnight developing. Morning surprise.'),
  DevelopDelay('3 days', Duration(days: 3), 'A long weekend of waiting.'),
  DevelopDelay('1 week', Duration(days: 7), 'The real thing. Maximum anticipation.'),
];

const defaultDevelopDelay = Duration(seconds: 15);
const rollSize = 36;
const abandonedRollDevelopTime = Duration(seconds: 5);

class Roll {
  final String id;
  final String name;
  final DateTime createdAt;
  FilmStock stock;
  final List<String> photos;
  final List<String> photoStocks;
  DateTime? completedAt;
  DateTime? developAt;

  Roll({
    required this.id,
    required this.name,
    required this.createdAt,
    this.stock = FilmStock.classic,
    List<String>? photos,
    List<String>? photoStocks,
    this.completedAt,
    this.developAt,
  }) : photos = photos ?? [],
       photoStocks = photoStocks ?? [];

  /// "MIXED" when photos were shot on more than one stock, the stock's name
  /// when it's a single non-Classic one, otherwise null.
  String? get stockLabel {
    final used = photoStocks.toSet();
    if (used.length > 1) return 'MIXED';
    if (used.length == 1 && used.first != FilmStock.classic.name) {
      return (FilmStock.values.asNameMap()[used.first] ?? FilmStock.classic)
          .label
          .toUpperCase();
    }
    return null;
  }

  bool get isShooting => completedAt == null;
  bool get isDeveloped =>
      developAt != null && !DateTime.now().isBefore(developAt!);
  bool get isDeveloping => completedAt != null && !isDeveloped;

  Duration get timeRemaining {
    if (developAt == null) return Duration.zero;
    final left = developAt!.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  double get developProgress {
    if (completedAt == null || developAt == null) return 0;
    final total = developAt!.difference(completedAt!).inMilliseconds;
    if (total <= 0) return 1;
    final elapsed = DateTime.now().difference(completedAt!).inMilliseconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'stock': stock.name,
    'photos': photos,
    'photoStocks': photoStocks,
    'completedAt': completedAt?.toIso8601String(),
    'developAt': developAt?.toIso8601String(),
  };

  factory Roll.fromJson(Map<String, dynamic> json) => Roll(
    id: json['id'] as String,
    name: json['name'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    stock: FilmStock.values.asNameMap()[json['stock']] ?? FilmStock.classic,
    photos: List<String>.from(json['photos'] as List),
    photoStocks:
        json['photoStocks'] == null
            ? List.filled(
              (json['photos'] as List).length,
              (json['stock'] as String?) ?? FilmStock.classic.name,
              growable: true,
            )
            : List<String>.from(json['photoStocks'] as List),
    completedAt:
        json['completedAt'] == null
            ? null
            : DateTime.parse(json['completedAt'] as String),
    developAt:
        json['developAt'] == null
            ? null
            : DateTime.parse(json['developAt'] as String),
  );
}

String formatRemaining(Duration d) {
  if (d.inDays >= 1) return '${d.inDays}d ${d.inHours % 24}h';
  if (d.inHours >= 1) return '${d.inHours}h ${d.inMinutes % 60}m';
  if (d.inMinutes >= 1) return '${d.inMinutes}m ${d.inSeconds % 60}s';
  return '${d.inSeconds}s';
}

/// Big and small lines for the Developing screen countdown, e.g. ('2d', '14 hrs 32 min').
(String, String) countdownParts(Duration d) {
  if (d.inDays >= 1) return ('${d.inDays}d', '${d.inHours % 24} hrs ${d.inMinutes % 60} min');
  if (d.inHours >= 1) return ('${d.inHours}h', '${d.inMinutes % 60} min ${d.inSeconds % 60} sec');
  final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
  return ('${d.inMinutes}:$seconds', 'min : sec');
}

/// "Saturday, Nov 2" for a moment more than a day away, otherwise "9:41 PM".
String readyOnLabel(DateTime when, {DateTime? now}) {
  const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  if (when.difference(now ?? DateTime.now()).inHours >= 24) {
    return '${weekdays[when.weekday - 1]}, ${months[when.month - 1]} ${when.day}';
  }
  final hour = when.hour % 12 == 0 ? 12 : when.hour % 12;
  final minute = when.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${when.hour >= 12 ? 'PM' : 'AM'}';
}

String dateLabel(DateTime d) {
  const months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];
  return '${months[d.month - 1]} ${d.day}';
}

/// Rolls, their photos, and the develop-time setting. Photos are kept in the
/// app's private storage (not the Photos library) until a roll is developed.
/// Only file names are persisted; the container path changes between app
/// updates on iOS, so absolute paths would go stale.
class RollStore extends ChangeNotifier {
  RollStore._();
  static final RollStore instance = RollStore._();

  static const _uuid = Uuid();

  Directory? _root;
  final List<Roll> _rolls = [];
  Duration _developDelay = defaultDevelopDelay;

  List<Roll> get rolls => List.unmodifiable(_rolls);
  Duration get developDelay => _developDelay;

  Roll? get currentRoll {
    for (final roll in _rolls.reversed) {
      if (roll.isShooting) return roll;
    }
    return null;
  }

  List<Roll> get finishedRolls =>
      _rolls.where((r) => !r.isShooting).toList()
        ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

  bool get hasDevelopingRolls => _rolls.any((r) => r.isDeveloping);

  Roll? roll(String id) {
    for (final r in _rolls) {
      if (r.id == id) return r;
    }
    return null;
  }

  File photoFile(Roll roll, String fileName) =>
      File('${_root!.path}/rolls/${roll.id}/$fileName');

  Future<void> load({Directory? root}) async {
    _root = root ?? await getApplicationDocumentsDirectory();
    _rolls.clear();
    _developDelay = defaultDevelopDelay;
    var themeMode = AppThemeMode.vintage;
    final file = _storeFile;
    if (await file.exists()) {
      try {
        final data =
            jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        _developDelay = Duration(
          seconds:
              data['developDelaySeconds'] as int? ??
              defaultDevelopDelay.inSeconds,
        );
        for (final r in data['rolls'] as List) {
          _rolls.add(Roll.fromJson(r as Map<String, dynamic>));
        }
        themeMode =
            AppThemeMode.values.asNameMap()[data['themeMode']] ??
            AppThemeMode.vintage;
      } catch (e) {
        debugPrint('Could not read roll store: $e');
      }
    }
    ThemeController.instance.removeListener(_save);
    ThemeController.instance.setMode(themeMode);
    ThemeController.instance.addListener(_save);
    notifyListeners();
  }

  Future<Roll> createRoll(
    String name, {
    FilmStock stock = FilmStock.classic,
  }) async {
    final roll = Roll(
      id: _uuid.v4(),
      name: name,
      createdAt: DateTime.now(),
      stock: stock,
    );
    _rolls.add(roll);
    await _save();
    notifyListeners();
    return roll;
  }

  Future<bool> addPhoto(String rollId, File source, {FilmStock? stock}) async {
    final roll = this.roll(rollId);
    if (roll == null || roll.photos.length >= rollSize || _root == null)
      return false;
    try {
      final dir = Directory('${_root!.path}/rolls/${roll.id}');
      await dir.create(recursive: true);
      final fileName = '${_uuid.v4()}.jpg';
      await source.copy('${dir.path}/$fileName');
      roll.photos.add(fileName);
      roll.photoStocks.add((stock ?? roll.stock).name);
      await _save();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error saving photo: $e');
      return false;
    }
  }

  Future<void> setStock(String rollId, FilmStock stock) async {
    final roll = this.roll(rollId);
    if (roll == null || roll.stock == stock) return;
    roll.stock = stock;
 notifyListeners();
 await _save();
  }

  /// Ends a roll early. It develops with whatever was shot, on a fixed short
  /// timer regardless of the develop-time setting; an empty roll is discarded.
  Future<void> abandonRoll(String rollId) async {
    final roll = this.roll(rollId);
    if (roll == null || roll.completedAt != null) return;
    if (roll.photos.isEmpty) {
      await deleteRoll(rollId);
      return;
    }
    await finishRoll(rollId, delay: abandonedRollDevelopTime);
  }

  Future<void> finishRoll(String rollId, {Duration? delay}) async {
    final roll = this.roll(rollId);
    if (roll == null || roll.completedAt != null) return;
    final now = DateTime.now();
    roll.completedAt = now;
    roll.developAt = now.add(delay ?? _developDelay);
    await _save();
    notifyListeners();
  }

  Future<void> deleteRoll(String rollId) async {
    final roll = this.roll(rollId);
    if (roll == null) return;
    _rolls.remove(roll);
    if (_root != null) {
      final dir = Directory('${_root!.path}/rolls/${roll.id}');
      try {
        if (await dir.exists()) await dir.delete(recursive: true);
      } catch (e) {
        debugPrint('Error deleting roll photos: $e');
      }
    }
    await _save();
    notifyListeners();
  }

  Future<void> setDevelopDelay(Duration delay) async {
    _developDelay = delay;
 notifyListeners();
 await _save();
  }

  File get _storeFile => File('${_root!.path}/store.json');

  Future<void> _save() async {
    if (_root == null) return;
    final data = {
      'developDelaySeconds': _developDelay.inSeconds,
      'themeMode': ThemeController.instance.mode.name,
      'rolls': _rolls.map((r) => r.toJson()).toList(),
    };
    try {
      await _storeFile.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('Could not save roll store: $e');
    }
  }
}
