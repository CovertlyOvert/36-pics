import 'package:flutter/material.dart';
import 'package:thirtysix_pics/services/roll_store.dart';
import 'package:thirtysix_pics/theme/theme.dart';

class YouScreen extends StatefulWidget {
  const YouScreen({super.key});

  @override
  State<YouScreen> createState() => _YouScreenState();
}

class _YouScreenState extends State<YouScreen> {
  @override
  void initState() {
    super.initState();
    ThemeController.instance.addListener(_onThemeChanged);
    RollStore.instance.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeController.instance.removeListener(_onThemeChanged);
    RollStore.instance.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('You', style: TextStyle(fontFamily: AppFonts.heading, color: AppColors.foreground)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        children: [
          Text(
            'APPEARANCE',
            style: TextStyle(
              fontFamily: AppFonts.mono,
              fontSize: 11,
              letterSpacing: 1.5,
              color: AppColors.foregroundSoft,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ThemeOptionCard(
                  label: 'Vintage',
                  description: 'Cream & brown',
                  previewColors: const [Color(0xFFFAF3E0), Color(0xFF704214)],
                  selected: ThemeController.instance.mode == AppThemeMode.vintage,
                  onTap: () => ThemeController.instance.setMode(AppThemeMode.vintage),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ThemeOptionCard(
                  label: 'Darkroom',
                  description: 'Safelight red',
                  previewColors: const [Color(0xFF1E1A17), Color(0xFFB2362A)],
                  selected: ThemeController.instance.mode == AppThemeMode.darkroom,
                  onTap: () => ThemeController.instance.setMode(AppThemeMode.darkroom),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'DEVELOPING TIME',
            style: TextStyle(
              fontFamily: AppFonts.mono,
              fontSize: 11,
              letterSpacing: 1.5,
              color: AppColors.foregroundSoft,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'How long a finished roll takes to develop before you can see it. Applies to rolls you finish from now on.',
            style: TextStyle(fontSize: 13, height: 1.35, color: AppColors.foregroundSoft),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final option in developDelayOptions)
                _DelayChip(
                  label: option.label,
                  selected: RollStore.instance.developDelay == option.duration,
                  onTap: () => RollStore.instance.setDevelopDelay(option.duration),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DelayChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DelayChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.card,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.primaryForeground : AppColors.cardForeground,
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  final String label;
  final String description;
  final List<Color> previewColors;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOptionCard({
    required this.label,
    required this.description,
    required this.previewColors,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: previewColors),
                    ),
                  ),
                  if (selected)
                    Icon(Icons.check_circle, color: AppColors.primary, size: 20)
                  else
                    Icon(Icons.radio_button_unchecked, color: AppColors.border, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppFonts.heading,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.cardForeground,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: AppColors.cardForeground.withOpacity(0.6)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
