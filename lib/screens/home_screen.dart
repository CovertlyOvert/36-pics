import 'dart:async';
import 'package:flutter/material.dart';
import 'package:thirtysix_pics/screens/roll_actions.dart';
import 'package:thirtysix_pics/services/roll_store.dart';
import 'package:thirtysix_pics/theme/theme.dart';
import 'package:thirtysix_pics/widgets/confirm_delete_roll.dart';
import 'package:thirtysix_pics/widgets/frame_counter_dial.dart';
import 'package:thirtysix_pics/widgets/roll_card.dart';
import 'package:thirtysix_pics/widgets/sprocket_mark.dart';
import 'package:thirtysix_pics/widgets/you_button.dart';

/// How many developed rolls Home previews before pointing at the Rolls tab.
const homeRecentRolls = 4;

/// The "now" tab: the roll in the camera, anything still developing, and the
/// latest developed rolls. The full archive lives on the Rolls tab.
class HomeScreen extends StatefulWidget {
  final VoidCallback? onSeeAllRolls;

  const HomeScreen({super.key, this.onSeeAllRolls});

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

  @override
  Widget build(BuildContext context) {
    final current = RollStore.instance.currentRoll;
    final finished = RollStore.instance.finishedRolls;
    final developing = finished.where((r) => r.isDeveloping).toList();
    final developed = finished.where((r) => r.isDeveloped).toList();
    final recent = developed.take(homeRecentRolls).toList();
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
                        const Spacer(),
                        const YouButton(),
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
                          ? () => loadNewFilm(context)
                          : () => openCamera(context, current),
                  onAbandon:
                      current == null
                          ? null
                          : () => abandonCurrentRoll(context, current),
                ),
              ),
            ),
            if (developing.isNotEmpty) ...[
              _sectionHeader(
                'Developing',
                trailing: Text(
                  '${developing.length} in the tank',
                  style: TextStyle(
                    fontFamily: AppFonts.mono,
                    fontSize: 12,
                    color: AppColors.foregroundSoft,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.separated(
                  itemCount: developing.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder:
                      (context, i) => _DevelopingRow(
                        roll: developing[i],
                        onTap: () => openRoll(context, developing[i]),
                        onLongPress:
                            () => confirmDeleteRoll(context, developing[i]),
                      ),
                ),
              ),
            ],
            _sectionHeader(
              'Recent Rolls',
              trailing:
                  finished.isEmpty
                      ? null
                      : TextButton(
                        onPressed: widget.onSeeAllRolls,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'See all ${finished.length} ›',
                          style: TextStyle(
                            fontFamily: AppFonts.mono,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
            ),
            if (finished.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                sliver: const SliverToBoxAdapter(child: EmptyRolls()),
              )
            else if (recent.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Nothing developed yet. Your first roll will land here.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.foregroundSoft,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.82,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final roll = recent[index];
                    return RollCard(
                      roll: roll,
                      rotation: index.isEven ? -0.02 : 0.018,
                      onTap: () => openRoll(context, roll),
                      onLongPress: () => confirmDeleteRoll(context, roll),
                    );
                  }, childCount: recent.length),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, {Widget? trailing}) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 14),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppFonts.heading,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing],
          ],
        ),
      ),
    );
  }
}

/// A roll in the tank: progress ring, name, and how long is left.
class _DevelopingRow extends StatelessWidget {
  final Roll roll;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _DevelopingRow({
    required this.roll,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  value: roll.developProgress,
                  strokeWidth: 4,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roll.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppFonts.heading,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.cardForeground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${roll.photos.length} exposures · ready ${readyOnLabel(roll.developAt!)}',
                      style: TextStyle(
                        fontFamily: AppFonts.mono,
                        fontSize: 10.5,
                        color: AppColors.cardForeground.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                formatRemaining(roll.timeRemaining),
                style: TextStyle(
                  fontFamily: AppFonts.mono,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
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
