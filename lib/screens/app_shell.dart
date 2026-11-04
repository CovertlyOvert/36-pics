import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thirtysix_pics/screens/home_screen.dart';
import 'package:thirtysix_pics/screens/roll_actions.dart';
import 'package:thirtysix_pics/screens/rolls_screen.dart';
import 'package:thirtysix_pics/theme/theme.dart';
import 'package:thirtysix_pics/widgets/app_tab_bar.dart';

/// Hosts the two tabs. They stay mounted (IndexedStack) so the Rolls filters
/// and scroll positions survive switching tabs.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppTab _tab = AppTab.home;

  @override
  void initState() {
    super.initState();
    ThemeController.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    ThemeController.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: statusBarStyle(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _tab.index,
          children: [
            HomeScreen(
              onSeeAllRolls: () => setState(() => _tab = AppTab.rolls),
            ),
            const RollsScreen(),
          ],
        ),
        bottomNavigationBar: AppTabBar(
          selected: _tab,
          onSelect: (tab) => setState(() => _tab = tab),
          onShutter: () => shootOrLoadFilm(context),
        ),
      ),
    );
  }
}
