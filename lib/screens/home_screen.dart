import 'dart:async';
import 'package:flutter/material.dart';
import 'package:thirtysix_pics/screens/camera_screen.dart';
import 'package:thirtysix_pics/screens/developing_screen.dart';
import 'package:thirtysix_pics/screens/gallery_screen.dart';
import 'package:thirtysix_pics/screens/you_screen.dart';
import 'package:thirtysix_pics/services/roll_store.dart';
import 'package:thirtysix_pics/theme/theme.dart';
import 'package:thirtysix_pics/widgets/confirm_abandon_roll.dart';
import 'package:thirtysix_pics/widgets/confirm_delete_roll.dart';
import 'package:thirtysix_pics/widgets/frame_counter_dial.dart';
import 'package:thirtysix_pics/widgets/new_roll_sheet.dart';
import 'package:thirtysix_pics/widgets/sprocket_mark.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    ThemeController.instance.addListener(_refresh);
    RollStore.instance.addListener(_refresh);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && RollStore.instance.hasDevelopingRolls) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    ThemeController.instance.removeListener(_refresh);
    RollStore.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _openCamera(Roll roll) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraScreen(rollId: roll.id)),
    );
  }

  Future<void> _loadNewFilm() async {
    final choice = await showNewRollSheet(context);
    if (choice == null || !mounted) return;
    final roll = await RollStore.instance.createRoll(
      choice.name,
      stock: choice.stock,
    );
    if (!mounted) return;
    _openCamera(roll);
  }

  Future<void> _abandon(Roll roll) async {
    final hadPhotos = roll.photos.isNotEmpty;
    if (!await confirmAbandonRoll(context, roll) || !mounted || !hadPhotos)
      return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DevelopingScreen(rollId: roll.id),
      ),
    );
  }

  void _onShutterTab() {
    final current = RollStore.instance.currentRoll;
    if (current != null) {
      _openCamera(current);
    } else {
      _loadNewFilm();
    }
  }

  void _openRoll(Roll roll) {
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

  @override
  Widget build(BuildContext context) {
    final current = RollStore.instance.currentRoll;
    final finished = RollStore.instance.finishedRolls;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
  children: [
    SprocketMark(size: 22, color: AppColors.primary),
    const SizedBox(width: 8),
    Text(
      '36 PICS',
      style: TextStyle(
        fontFamily: AppFonts.mono,
        fontSize: 11,
        letterSpacing: 2,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    ),
  ],
),
                    Text(
                      'Exposures',
                      style: TextStyle(
                        fontFamily: AppFonts.heading,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        height: 1.05,
                        color: AppColors.foreground,
                      ),
                    ),
                    Text(
                      "Shot on film. Seen when it's ready.",
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppColors.foregroundSoft,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _CurrentRollCard(
                  roll: current,
                  onContinue:
                      current == null
                          ? _loadNewFilm
                          : () => _openCamera(current),
                  onAbandon: current == null ? null : () => _abandon(current),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 14),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Finished Rolls',
                      style: TextStyle(
                        fontFamily: AppFonts.heading,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.foreground,
                      ),
                    ),
                    Text(
                      '${finished.length} ${finished.length == 1 ? 'roll' : 'rolls'}',
                      style: TextStyle(
                        fontFamily: AppFonts.mono,
                        fontSize: 12,
                        color: AppColors.foregroundSoft,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (finished.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 110),
                sliver: SliverToBoxAdapter(
                  child: const _EmptyFinishedRolls(),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.82,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final roll = finished[index];
                    return _FinishedRollCard(
                      roll: roll,
                      rotation: index.isEven ? -0.02 : 0.018,
                      onTap: () => _openRoll(roll),
                      onLongPress: () => confirmDeleteRoll(context, roll),
                    );
                  }, childCount: finished.length),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomTabBar(
        onOpenCamera: _onShutterTab,
        onOpenYou:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const YouScreen()),
            ),
      ),
    );
  }
}

class _CurrentRollCard extends StatelessWidget {
  final Roll? roll;
  final VoidCallback onContinue;
  final VoidCallback? onAbandon;

  const _CurrentRollCard({
    required this.roll,
    required this.onContinue,
    this.onAbandon,
  });

  @override
  Widget build(BuildContext context) {
    final roll = this.roll;
    final count = roll?.photos.length ?? 0;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDeep],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDeep.withOpacity(0.45),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roll == null ? 'NO FILM LOADED' : 'CURRENTLY SHOOTING',
style: TextStyle(
  fontFamily: AppFonts.mono,
  fontSize: 11,
  letterSpacing: 1.8,
  fontWeight: FontWeight.bold,
  color: AppColors.primaryForeground,
),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      roll?.name ?? 'Start a new roll',
maxLines: 2,
overflow: TextOverflow.ellipsis,
style: TextStyle(
  fontFamily: AppFonts.heading,
  fontWeight: FontWeight.bold,
  fontSize: 24,
                        color: AppColors.primaryForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      roll == null ? '36 shots. Make them count.' : '$count of $rollSize exposed',
style: TextStyle(
  fontSize: 13,
  color: AppColors.primaryForeground.withOpacity(0.92),
                      ),
                    ),
                  ],
                ),
              ),
              FrameCounterDial(
  current: count,
  total: rollSize,
  size: 112,
  strokeFraction: 0.08,
  centerText: '${rollSize - count}',
  caption: 'SHOTS LEFT',
  centerFontFamily: AppFonts.heading,
  ringColor: Colors.white.withOpacity(0.22),
                progressColor: AppColors.primaryForeground,
                textColor: AppColors.primaryForeground,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryForeground,
                foregroundColor: AppColors.primaryDeep,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: Icon(
                roll == null
                    ? Icons.movie_filter_outlined
                    : Icons.camera_alt_outlined,
                size: 18,
              ),
              label: Text(
                roll == null ? 'Load New Film' : 'Continue Shooting',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.5,
                ),
              ),
            ),
          ),
          if (onAbandon != null) ...[
            const SizedBox(height: 4),
            TextButton(
              onPressed: onAbandon,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryForeground.withOpacity(0.8),
                minimumSize: const Size.fromHeight(44),
              ),
              child: const Text('Abandon film', style: TextStyle(fontSize: 13)),
            ),
          ],
        ],
      ),
    );
  }
}

class _FinishedRollCard extends StatelessWidget {
  final Roll roll;
  final double rotation;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _FinishedRollCard({
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
                          ? _PhotoCollage(roll: roll)
                          : _DevelopingTile(roll: roll),
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

class _DevelopingTile extends StatelessWidget {
  final Roll roll;

  const _DevelopingTile({required this.roll});

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

class _EmptyFinishedRolls extends StatelessWidget {
  const _EmptyFinishedRolls();

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
          'Load your first roll above to begin.',
          style: TextStyle(fontSize: 13, color: AppColors.foregroundSoft),
        ),
      ],
    );
  }
}

class _PhotoCollage extends StatelessWidget {
  final Roll roll;

  const _PhotoCollage({required this.roll});

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

class _BottomTabBar extends StatelessWidget {
  final VoidCallback onOpenCamera;
  final VoidCallback onOpenYou;

  const _BottomTabBar({required this.onOpenCamera, required this.onOpenYou});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 10,
        top: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.muted,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _TabBarItem(
            icon: Icons.grid_view_rounded,
            label: 'ROLLS',
            active: true,
            onTap: () {},
          ),
          GestureDetector(
            onTap: onOpenCamera,
            child: Transform.translate(
              offset: const Offset(0, -26),
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  border: Border.all(color: AppColors.background, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.5),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: AppColors.primaryForeground,
                  size: 24,
                ),
              ),
            ),
          ),
          _TabBarItem(
            icon: Icons.person_outline,
            label: 'YOU',
            active: false,
            onTap: onOpenYou,
          ),
        ],
      ),
    );
  }
}

class _TabBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabBarItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor =
    ThemeController.instance.mode == AppThemeMode.darkroom ? AppColors.foreground : AppColors.primaryDeep;
final color = active ? activeColor : AppColors.foregroundSoft;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.mono,
                fontSize: 9.5,
                letterSpacing: .5,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
