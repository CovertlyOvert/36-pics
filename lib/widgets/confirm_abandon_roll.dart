import 'package:flutter/material.dart';
import 'package:thirtysix_pics/services/roll_store.dart';
import 'package:thirtysix_pics/theme/theme.dart';

/// Asks before ending a roll early. Returns true if the roll was abandoned
/// (developed with what was shot, or discarded if it was empty).
Future<bool> confirmAbandonRoll(BuildContext context, Roll roll) async {
  final shots = roll.photos.length;
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            'Abandon "${roll.name}"?',
            style: TextStyle(
              fontFamily: AppFonts.heading,
              color: AppColors.cardForeground,
            ),
          ),
          content: Text(
            shots == 0
                ? 'Nothing has been shot on this roll yet, so it will simply be discarded.'
                : 'The roll will be sealed with the $shots ${shots == 1 ? 'photo' : 'photos'} you\'ve taken and '
                    'develop right away. You can\'t add more shots to it afterwards.',
            style: TextStyle(color: AppColors.cardForeground.withOpacity(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep shooting'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
              child: Text(shots == 0 ? 'Discard' : 'Abandon'),
            ),
          ],
        ),
  );
  if (confirmed != true) return false;
  await RollStore.instance.abandonRoll(roll.id);
  return true;
}
