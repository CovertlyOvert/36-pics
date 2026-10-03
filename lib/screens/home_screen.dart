import 'package:flutter/material.dart';
import 'package:thirtysix_pics/screens/camera_screen.dart';
import 'package:thirtysix_pics/screens/gallery_screen.dart';
import 'package:thirtysix_pics/screens/you_screen.dart';
import 'package:thirtysix_pics/theme/theme.dart';
import 'package:thirtysix_pics/widgets/frame_counter_dial.dart';
import 'package:thirtysix_pics/widgets/new_roll_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _currentRoll = (name: "Euro Trip '25", route: 'Rome → Florence → Venice', count: 14);

  static const _developedRolls = [
    (name: 'Goa 2025', date: 'MAR 12', count: 28),
    (name: 'Manali 2024', date: 'JAN 5', count: 36),
    (name: 'Kerala Backwaters', date: 'DEC 15', count: 21),
  ];

  @override
  void initState() {
    super.initState();
    ThemeController.instance.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeController.instance.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});

  Future<void> _openNewRollSheet(BuildContext context) async {
    final tripName = await showNewRollSheet(context);
    if (tripName == null || !context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraScreen(tripName: tripName)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              sliver: SliverToBoxAdapter(child: _CurrentRollCard(roll: _currentRoll)),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 14),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Developed Rolls',
                      style: TextStyle(
                        fontFamily: AppFonts.heading,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.foreground,
                      ),
                    ),
                    Text(
                      _developedRolls.length.toString().padLeft(3, '0'),
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
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.82,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final roll = _developedRolls[index];
                    return _DevelopedRollCard(
                      roll: roll,
                      rotation: index.isEven ? -0.02 : 0.018,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GalleryScreen(
                            tripName: roll.name,
                            dateLabel: roll.date,
                            photoCount: roll.count,
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: _developedRolls.length,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomTabBar(
        onOpenCamera: () => _openNewRollSheet(context),
        onOpenYou: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const YouScreen()),
        ),
      ),
    );
  }
}

class _CurrentRollCard extends StatelessWidget {
  final ({String name, String route, int count}) roll;

  const _CurrentRollCard({required this.roll});

  @override
  Widget build(BuildContext context) {
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
                      'CURRENTLY SHOOTING',
                      style: TextStyle(
                        fontFamily: AppFonts.mono,
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryForeground.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      roll.name,
                      style: TextStyle(
                        fontFamily: AppFonts.heading,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: AppColors.primaryForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      roll.route,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.primaryForeground.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              FrameCounterDial(
                current: roll.count,
                total: 36,
                ringColor: Colors.white.withOpacity(0.2),
                progressColor: AppColors.primaryForeground,
                textColor: AppColors.primaryForeground,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CameraScreen(
                    tripName: roll.name,
                    initialPhotoCount: roll.count,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryForeground,
                foregroundColor: AppColors.primaryDeep,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: const Icon(Icons.camera_alt_outlined, size: 18),
              label: Text(
                'Continue Shooting',
                style: TextStyle(fontFamily: AppFonts.body, fontWeight: FontWeight.w600, fontSize: 14.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DevelopedRollCard extends StatelessWidget {
  final ({String name, String date, int count}) roll;
  final double rotation;
  final VoidCallback onTap;

  const _DevelopedRollCard({required this.roll, required this.rotation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
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
                Expanded(child: _PhotoCollagePlaceholder(seed: roll.name.hashCode)),
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
                  '${roll.count}/36 · ${roll.date}',
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

/// A 2x2 collage of soft gradient tiles standing in for real photo
/// thumbnails — this app has no stored images yet, so the grid is
/// seeded per-roll purely for visual variety.
class _PhotoCollagePlaceholder extends StatelessWidget {
  final int seed;

  const _PhotoCollagePlaceholder({required this.seed});

  static const _palette = [
    [Color(0xFFE7A05A), Color(0xFFC1472B)],
    [Color(0xFF8FB9C9), Color(0xFF3E6E7E)],
    [Color(0xFFD9C79A), Color(0xFFA8842F)],
    [Color(0xFFC98A9A), Color(0xFF7C3E4F)],
    [Color(0xFF9FB88A), Color(0xFF4E6E3E)],
    [Color(0xFF7FAFC9), Color(0xFF2E5E7E)],
  ];

  @override
  Widget build(BuildContext context) {
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
          final colors = _palette[(seed.abs() + index) % _palette.length];
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
            ),
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
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 10, top: 10),
      decoration: BoxDecoration(
        color: AppColors.muted,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _TabBarItem(icon: Icons.grid_view_rounded, label: 'ROLLS', active: true, onTap: () {}),
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
                child: Icon(Icons.camera_alt, color: AppColors.primaryForeground, size: 24),
              ),
            ),
          ),
          _TabBarItem(icon: Icons.person_outline, label: 'YOU', active: false, onTap: onOpenYou),
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
    final color = active ? AppColors.primaryDeep : AppColors.foregroundSoft;
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
              style: TextStyle(fontFamily: AppFonts.mono, fontSize: 9.5, letterSpacing: .5, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
