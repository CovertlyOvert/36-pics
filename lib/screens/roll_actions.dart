import 'package:flutter/material.dart';
import 'package:thirtysix_pics/screens/camera_screen.dart';
import 'package:thirtysix_pics/screens/developing_screen.dart';
import 'package:thirtysix_pics/screens/gallery_screen.dart';
import 'package:thirtysix_pics/services/roll_store.dart';
import 'package:thirtysix_pics/widgets/confirm_abandon_roll.dart';
import 'package:thirtysix_pics/widgets/new_roll_sheet.dart';

/// Navigation and flows shared by the Home and Rolls tabs.

void openCamera(BuildContext context, Roll roll) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => CameraScreen(rollId: roll.id)),
  );
}

Future<void> loadNewFilm(BuildContext context) async {
  final choice = await showNewRollSheet(context);
  if (choice == null || !context.mounted) return;
  final roll = await RollStore.instance.createRoll(
    choice.name,
    stock: choice.stock,
  );
  if (!context.mounted) return;
  openCamera(context, roll);
}

/// Continues the roll being shot, or offers to load a new one.
void shootOrLoadFilm(BuildContext context) {
  final current = RollStore.instance.currentRoll;
  if (current != null) {
    openCamera(context, current);
  } else {
    loadNewFilm(context);
  }
}

Future<void> abandonCurrentRoll(BuildContext context, Roll roll) async {
  final hadPhotos = roll.photos.isNotEmpty;
  if (!await confirmAbandonRoll(context, roll) ||
      !context.mounted ||
      !hadPhotos) {
    return;
  }
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => DevelopingScreen(rollId: roll.id)),
  );
}

void openRoll(BuildContext context, Roll roll) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder:
          (context) =>
              roll.isDeveloped
                  ? GalleryScreen(rollId: roll.id)
                  : DevelopingScreen(rollId: roll.id),
    ),
  );
}
