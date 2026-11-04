import 'package:flutter/material.dart';
import 'package:thirtysix_pics/theme/theme.dart';

enum AppTab { home, rolls }

/// Bottom bar: HOME, the shutter in the centre, ROLLS. The shutter is an action
/// (shoot / load film), not a destination, so it never shows as selected.
class AppTabBar extends StatelessWidget {
  final AppTab selected;
  final ValueChanged<AppTab> onSelect;
  final VoidCallback onShutter;

  const AppTabBar({
    super.key,
    required this.selected,
    required this.onSelect,
    required this.onShutter,
  });

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
        children: [
          Expanded(
            child: _TabBarItem(
              icon: Icons.home_outlined,
              label: 'HOME',
              active: selected == AppTab.home,
              onTap: () => onSelect(AppTab.home),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onShutter,
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
          ),
          Expanded(
            child: _TabBarItem(
              icon: Icons.grid_view_rounded,
              label: 'ROLLS',
              active: selected == AppTab.rolls,
              onTap: () => onSelect(AppTab.rolls),
            ),
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
        ThemeController.instance.mode == AppThemeMode.darkroom
            ? AppColors.foreground
            : AppColors.primaryDeep;
    final color = active ? activeColor : AppColors.foregroundSoft;
    return InkWell(
      onTap: onTap,
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
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
