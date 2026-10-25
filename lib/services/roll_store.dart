import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class DevelopDelay {
  final String label;
  final Duration duration;

  const DevelopDelay(this.label, this.duration);
}

const developDelayOptions = [
  DevelopDelay('15 seconds', Duration(seconds: 15)),
  DevelopDelay('1 hour', Duration(hours: 1)),
  DevelopDelay('6 hours', Duration(hours: 6)),
  DevelopDelay('1 day', Duration(days: 1)),
  DevelopDelay('3 days', Duration(days: 3)),
  DevelopDelay('1 week', Duration(days: 7)),
];

const defaultDevelopDelay = Duration(seconds: 15);
const rollSize = 36;

class Roll {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<String> photos;
  DateTime? completedAt;
  DateTime? developAt;

  Roll({
    required this.id,
    required this.name,
    required this.createdAt,
    List<String>? photos,
    this.completedAt,
    this.developAt,
  }) : photos = photos ?? [];

  bool get isShooting => completedAt == null;
  bool get isDeveloped => developAt != null && !DateTime.now().isBefore(developAt!);
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
        'photos': photos,
        'completedAt': completedAt?.toIso8601String(),
        'developAt': developAt?.toIso8601String(),
      };

  factory Roll.fromJson(Map<String, dynamic> json) => Roll(
        id: json['id'] as String,
        name: json['name'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        photos: List<String>.from(json['photos'] as List),
        completedAt: json['completedAt'] == null ? null : DateTime.parse(json['completedAt'] as String),
        developAt: json['developAt'] == null ? null : DateTime.parse(json['developAt'] as String),
      );
}

String formatRemaining(Duration d) {
  if (d.inDays >= 1) return '${d.inDays}d ${d.inHours % 24}h';
  if (d.inHours >= 1) return '${d.inHours}h ${d.inMinutes % 60}m';
  if (d.inMinutes >= 1) return '${d.inMinutes}m ${d.inSeconds % 60}s';
  return '${d.inSeconds}s';
}

String dateLabel(DateTime d) {
  const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
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
      _rolls.where((r) => !r.isShooting).toList()..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

  bool get hasDevelopingRolls => _rolls.any((r) => r.isDeveloping);

  Roll? roll(String id) {
    for (final r in _rolls) {
      if (r.id == id) return r;
    }
    return null;
  }

  File photoFile(Roll roll, String fileName) => File('${_root!.path}/rolls/${roll.id}/$fileName');

  Future<void> load({Directory? root}) async {
    _root = root ?? await getApplicationDocumentsDirectory();
    _rolls.clear();
    _developDelay = defaultDevelopDelay;
    final file = _storeFile;
    if (await file.exists()) {
      try {
        final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        _developDelay = Duration(seconds: data['developDelaySeconds'] as int? ?? defaultDevelopDelay.inSeconds);
        for (final r in data['rolls'] as List) {
          _rolls.add(Roll.fromJson(r as Map<String, dynamic>));
        }
      } catch (e) {
        debugPrint('Could not read roll store: $e');
      }
    }
    notifyListeners();
  }

  Future<Roll> createRoll(String name) async {
    final roll = Roll(id: _uuid.v4(), name: name, createdAt: DateTime.now());
    _rolls.add(roll);
    await _save();
    notifyListeners();
    return roll;
  }

  Future<bool> addPhoto(String rollId, File source) async {
    final roll = this.roll(rollId);
    if (roll == null || roll.photos.length >= rollSize || _root == null) return false;
    try {
      final dir = Directory('${_root!.path}/rolls/${roll.id}');
      await dir.create(recursive: true);
      final fileName = '${_uuid.v4()}.jpg';
      await source.copy('${dir.path}/$fileName');
      roll.photos.add(fileName);
      await _save();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error saving photo: $e');
      return false;
    }
  }

  Future<void> finishRoll(String rollId) async {
    final roll = this.roll(rollId);
    if (roll == null || roll.completedAt != null) return;
    final now = DateTime.now();
    roll.completedAt = now;
    roll.developAt = now.add(_developDelay);
    await _save();
    notifyListeners();
  }

  Future<void> setDevelopDelay(Duration delay) async {
    _developDelay = delay;
    await _save();
    notifyListeners();
  }

  File get _storeFile => File('${_root!.path}/store.json');

  Future<void> _save() async {
    if (_root == null) return;
    final data = {
      'developDelaySeconds': _developDelay.inSeconds,
      'rolls': _rolls.map((r) => r.toJson()).toList(),
    };
    await _storeFile.writeAsString(jsonEncode(data));
  }
}
