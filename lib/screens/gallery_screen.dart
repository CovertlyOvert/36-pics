import 'dart:io';

import 'package:flutter/material.dart';
import 'package:thirtysix_pics/services/photo_service.dart';
import 'package:thirtysix_pics/services/roll_store.dart';
import 'package:thirtysix_pics/theme/theme.dart';
import 'package:thirtysix_pics/widgets/confirm_delete_roll.dart';

class GalleryScreen extends StatelessWidget {
  final String rollId;

  const GalleryScreen({super.key, required this.rollId});

  Future<void> _saveAll(BuildContext context, Roll roll, List<File> files) async {
    final messenger = ScaffoldMessenger.of(context);
    final albumName = '36 Pics - ${roll.name}';
    final choice = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_album_outlined, color: AppColors.primary),
                title: Text('Save as album', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.cardForeground)),
                subtitle: Text('Creates "$albumName" in Photos', style: TextStyle(color: AppColors.cardForeground.withOpacity(0.6))),
                onTap: () => Navigator.pop(context, true),
              ),
              ListTile(
                leading: Icon(Icons.photo_library_outlined, color: AppColors.primary),
                title: Text('Save photos only', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.cardForeground)),
                subtitle: Text('Adds them to your library, no album', style: TextStyle(color: AppColors.cardForeground.withOpacity(0.6))),
                onTap: () => Navigator.pop(context, false),
              ),
            ],
          ),
        ),
      ),
    );
    if (choice == null) return;
    messenger.showSnackBar(const SnackBar(content: Text('Saving to Photos…')));
    final saved = await PhotoService.exportToGallery(files, albumName: choice ? albumName : null);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      content: Text(saved == files.length
          ? (choice ? 'Saved ${files.length} photos to album "$albumName"' : 'Saved ${files.length} photos to Photos')
          : 'Saved $saved of ${files.length} photos — check Photos access in Settings'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final roll = RollStore.instance.roll(rollId)!;
    final tripName = roll.name;
    final photoCount = roll.photos.length;
    final dateText = dateLabel(roll.completedAt ?? roll.createdAt);
    final files = [for (final name in roll.photos) RollStore.instance.photoFile(roll, name)];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.arrow_back_ios_new,
                    tooltip: 'Back to library',
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tripName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppFonts.heading,
                            fontWeight: FontWeight.bold,
                            fontSize: 21,
                            color: AppColors.foreground,
                          ),
                        ),
                        Text(
                          '$photoCount/36 · $dateText',
                          style: TextStyle(
                            fontFamily: AppFonts.mono,
                            fontSize: 10.5,
                            color: AppColors.foregroundSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _RoundIconButton(
                    icon: Icons.ios_share,
                    tooltip: 'Share options',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _FilmPerforationRow(count: photoCount),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.82,
                ),
                itemCount: photoCount,
                itemBuilder: (context, index) => _PolaroidPhoto(index: index, file: files[index]),
              ),
            ),
            _ActionToolbar(
              onSaveAll: () => _saveAll(context, roll, files),
              onDelete: () async {
                final navigator = Navigator.of(context);
                if (await confirmDeleteRoll(context, roll)) navigator.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PolaroidPhoto extends StatelessWidget {
  final int index;
  final File file;

  const _PolaroidPhoto({required this.index, required this.file});

  @override
  Widget build(BuildContext context) {
    final rotation = (index.isEven ? -1.0 : 1.0) * (1.5 + (index % 3));
    return Transform.rotate(
      angle: rotation * 3.14159265 / 180,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 14, offset: const Offset(0, 8)),
          ],
        ),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Image.file(
                file,
                fit: BoxFit.cover,
                cacheWidth: 600,
                errorBuilder: (context, error, stack) => ColoredBox(
                  color: const Color(0xFFE8E0D0),
                  child: const Center(child: Icon(Icons.broken_image_outlined, color: Color(0xFF8A7B6C))),
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 2,
              child: Text(
                'No.${(index + 1).toString().padLeft(2, '0')}',
                style: const TextStyle(fontFamily: 'Courier Prime', fontSize: 8.5, color: Color(0xFF8A7B6C)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilmPerforationRow extends StatelessWidget {
  final int count;

  const _FilmPerforationRow({required this.count});

  @override
  Widget build(BuildContext context) {
    final dots = count.clamp(6, 14);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          dots,
          (i) => Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.foregroundSoft.withOpacity(0.5)),
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      shape: const CircleBorder(),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.border)),
            child: Icon(icon, size: 16, color: AppColors.foreground),
          ),
        ),
      ),
    );
  }
}

class _ActionToolbar extends StatelessWidget {
  final VoidCallback onSaveAll;
  final VoidCallback onDelete;

  const _ActionToolbar({required this.onSaveAll, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 18, offset: const Offset(0, 8))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ToolbarAction(icon: Icons.ios_share, label: 'SHARE'),
            const SizedBox(width: 26),
            _ToolbarAction(icon: Icons.download_outlined, label: 'SAVE ALL', onTap: onSaveAll),
            const SizedBox(width: 26),
            _ToolbarAction(icon: Icons.delete_outline, label: 'DELETE', onTap: onDelete),
          ],
        ),
      ),
    );
  }
}

class _ToolbarAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ToolbarAction({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 19, color: AppColors.foreground),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontFamily: AppFonts.mono, fontSize: 8.5, letterSpacing: .5, color: AppColors.foreground),
          ),
        ],
      ),
    );
  }
}
