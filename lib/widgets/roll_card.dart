import 'package:flutter/material.dart';
import 'package:thirtysix_pics/services/roll_store.dart';
import 'package:thirtysix_pics/theme/theme.dart';

class RollCard extends StatelessWidget {
  final Roll roll;
  final double rotation;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const RollCard({
    super.key,
    required this.roll,
    required this.rotation,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final developed = roll.isDeveloped;
    return Transform.rotate(
      angle: rotation,
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child:
                      developed
                          ? PhotoCollage(roll: roll)
                          : DevelopingTile(roll: roll),
                ),
                const SizedBox(height: 10),
                Text(
                  roll.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.heading,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.cardForeground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  developed
                      ? '${roll.photos.length}/36 · ${dateLabel(roll.completedAt!)}'
                      : 'Ready ${dateLabel(roll.developAt!)}',
                  style: TextStyle(
                    fontFamily: AppFonts.mono,
                    fontSize: 10.5,
                    color: AppColors.cardForeground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DevelopingTile extends StatelessWidget {
  final Roll roll;

  const DevelopingTile({super.key, required this.roll});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDeep],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: SizedBox(
                width: 78,
                height: 78,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 78,
                      height: 78,
                      child: CircularProgressIndicator(
                        value: roll.developProgress,
                        strokeWidth: 4,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation(AppColors.primaryForeground),
                      ),
                    ),
                    Text(
                      formatRemaining(roll.timeRemaining),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppFonts.mono,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'DEV',
                  style: TextStyle(
                    fontFamily: AppFonts.mono,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: AppColors.primaryDeep,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyRolls extends StatelessWidget {
  final String hint;

  const EmptyRolls({super.key, this.hint = 'Load your first roll above to begin.'});

  @override
  Widget build(BuildContext context) {
    Widget holes() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            14,
            (_) => Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(1.5)),
            ),
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          decoration: BoxDecoration(
            color: AppColors.muted,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              holes(),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (var i = 1; i <= 3; i++) ...[
                    Expanded(
                      child: Container(
                        height: 54,
                        alignment: Alignment.bottomRight,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          '0$i',
                          style: TextStyle(fontFamily: AppFonts.mono, fontSize: 9, color: AppColors.foregroundSoft),
                        ),
                      ),
                    ),
                    if (i < 3) const SizedBox(width: 6),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              holes(),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Your rolls will develop here.',
          style: TextStyle(
            fontFamily: AppFonts.heading,
            fontStyle: FontStyle.italic,
            fontSize: 15,
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          hint,
          style: TextStyle(fontSize: 13, color: AppColors.foregroundSoft),
        ),
      ],
    );
  }
}

class PhotoCollage extends StatelessWidget {
  final Roll roll;

  const PhotoCollage({super.key, required this.roll});

  @override
  Widget build(BuildContext context) {
    final photos = roll.photos.take(4).toList();
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          if (index >= photos.length) return ColoredBox(color: AppColors.muted);
          return Image.file(
            RollStore.instance.photoFile(roll, photos[index]),
            fit: BoxFit.cover,
            cacheWidth: 300,
            errorBuilder:
                (context, error, stack) => ColoredBox(color: AppColors.muted),
          );
        },
      ),
    );
  }
}
