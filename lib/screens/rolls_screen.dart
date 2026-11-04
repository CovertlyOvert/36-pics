import 'dart:async';
import 'package:flutter/material.dart';
import 'package:thirtysix_pics/screens/roll_actions.dart';
import 'package:thirtysix_pics/services/film_stock.dart';
import 'package:thirtysix_pics/services/roll_store.dart';
import 'package:thirtysix_pics/theme/theme.dart';
import 'package:thirtysix_pics/widgets/confirm_delete_roll.dart';
import 'package:thirtysix_pics/widgets/roll_card.dart';
import 'package:thirtysix_pics/widgets/you_button.dart';

enum RollStatus { all, developing, ready }

/// Finished rolls matching [status] and [stock] (any frame shot on it),
/// ordered by when they were finished.
List<Roll> filterRolls(
  List<Roll> rolls, {
  RollStatus status = RollStatus.all,
  FilmStock? stock,
  bool newestFirst = true,
}) {
  final result =
      rolls.where((r) {
        if (r.isShooting) return false;
        final statusOk = switch (status) {
          RollStatus.all => true,
          RollStatus.developing => r.isDeveloping,
          RollStatus.ready => r.isDeveloped,
        };
        return statusOk && (stock == null || r.photoStocks.contains(stock.name));
      }).toList()..sort((a, b) => a.completedAt!.compareTo(b.completedAt!));
  return newestFirst ? result.reversed.toList() : result;
}

/// The archive: every finished roll, filterable by status and film stock.
class RollsScreen extends StatefulWidget {
  const RollsScreen({super.key});

  @override
  State<RollsScreen> createState() => _RollsScreenState();
}

class _RollsScreenState extends State<RollsScreen> {
  Timer? _ticker;
  RollStatus _status = RollStatus.all;
  FilmStock? _stock;
  bool _newestFirst = true;

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
    final all = RollStore.instance.finishedRolls;
    final photoCount = all.fold<int>(0, (sum, r) => sum + r.photos.length);
    final stocksUsed =
        FilmStock.values
            .where((s) => all.any((r) => r.photoStocks.contains(s.name)))
            .toList();
    // A stock that's no longer used by any roll (e.g. after a delete) can't
    // stay selected, or the list would look mysteriously empty.
    final stock = stocksUsed.contains(_stock) ? _stock : null;
    final rolls = filterRolls(
      all,
      status: _status,
      stock: stock,
      newestFirst: _newestFirst,
    );
    final filtered = _status != RollStatus.all || stock != null;

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
                        Text(
                          'ARCHIVE',
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
                      'Rolls',
                      style: TextStyle(
                        fontFamily: AppFonts.heading,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        height: 1.05,
                        color: AppColors.foreground,
                      ),
                    ),
                    Text(
                      '${all.length} ${all.length == 1 ? 'roll' : 'rolls'} · '
                      '$photoCount ${photoCount == 1 ? 'photo' : 'photos'}',
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
            if (all.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _ChipRow(
                  padding: const EdgeInsets.only(top: 20),
                  chips: [
                    for (final s in RollStatus.values)
                      _FilterChip(
                        label: _statusLabel(s, all),
                        selected: _status == s,
                        onTap: () => setState(() => _status = s),
                      ),
                  ],
                ),
              ),
              if (stocksUsed.length > 1)
                SliverToBoxAdapter(
                  child: _ChipRow(
                    padding: const EdgeInsets.only(top: 10),
                    chips: [
                      _FilterChip(
                        label: 'Any stock',
                        selected: stock == null,
                        onTap: () => setState(() => _stock = null),
                      ),
                      for (final s in stocksUsed)
                        _FilterChip(
                          label: s.label,
                          selected: stock == s,
                          onTap: () => setState(() => _stock = s),
                        ),
                    ],
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        filtered ? '${rolls.length} of ${all.length}' : '',
                        style: TextStyle(
                          fontFamily: AppFonts.mono,
                          fontSize: 12,
                          color: AppColors.foregroundSoft,
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => _newestFirst = !_newestFirst),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _newestFirst ? 'NEWEST FIRST' : 'OLDEST FIRST',
                                style: TextStyle(
                                  fontFamily: AppFonts.mono,
                                  fontSize: 11,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                _newestFirst
                                    ? Icons.arrow_downward_rounded
                                    : Icons.arrow_upward_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (all.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 48),
                sliver: const SliverToBoxAdapter(
                  child: EmptyRolls(
                    hint: 'Tap the shutter to load your first roll.',
                  ),
                ),
              )
            else if (rolls.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No rolls match.',
                        style: TextStyle(
                          fontFamily: AppFonts.heading,
                          fontStyle: FontStyle.italic,
                          fontSize: 15,
                          color: AppColors.foreground,
                        ),
                      ),
                      TextButton(
                        onPressed:
                            () => setState(() {
                              _status = RollStatus.all;
                              _stock = null;
                            }),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text('Clear filters'),
                      ),
                    ],
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
                    final roll = rolls[index];
                    return RollCard(
                      roll: roll,
                      rotation: index.isEven ? -0.02 : 0.018,
                      onTap: () => openRoll(context, roll),
                      onLongPress: () => confirmDeleteRoll(context, roll),
                    );
                  }, childCount: rolls.length),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(RollStatus s, List<Roll> all) {
    final count = filterRolls(all, status: s).length;
    final name = switch (s) {
      RollStatus.all => 'All',
      RollStatus.developing => 'Developing',
      RollStatus.ready => 'Ready',
    };
    return '$name $count';
  }
}

class _ChipRow extends StatelessWidget {
  final EdgeInsets padding;
  final List<Widget> chips;

  const _ChipRow({required this.padding, required this.chips});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: chips.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => chips[i],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.card,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.mono,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color:
                  selected
                      ? AppColors.primaryForeground
                      : AppColors.cardForeground,
            ),
          ),
        ),
      ),
    );
  }
}
