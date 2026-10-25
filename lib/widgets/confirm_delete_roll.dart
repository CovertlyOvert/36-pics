import 'package:flutter/material.dart';
import 'package:thirtysix_pics/services/roll_store.dart';
import 'package:thirtysix_pics/theme/theme.dart';

/// Asks before deleting a roll; returns true if it was deleted.
Future<bool> confirmDeleteRoll(BuildContext context, Roll roll) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.card,
      title: Text('Delete "${roll.name}"?', style: TextStyle(fontFamily: AppFonts.heading, color: AppColors.cardForeground)),
      content: Text(
        'This permanently removes the roll and its ${roll.photos.length} photos from 36 Pics. '
        'Copies you already saved to your Photos library are not affected.',
        style: TextStyle(color: AppColors.cardForeground.withOpacity(0.8)),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed != true) return false;
  await RollStore.instance.deleteRoll(roll.id);
  return true;
}
