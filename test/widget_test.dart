import 'package:flutter_test/flutter_test.dart';

import 'package:thirtysix_pics/main.dart';
import 'package:thirtysix_pics/theme/theme.dart';

void main() {
  tearDown(() => ThemeController.instance.setMode(AppThemeMode.vintage));

  testWidgets('Library screen shows title and roll data',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ThirtySixPicsApp());

    expect(find.text('Exposures'), findsOneWidget);
    expect(find.text("Euro Trip '25"), findsOneWidget);
    expect(find.text('Goa 2025'), findsOneWidget);
  });

  testWidgets('You screen can switch between Vintage and Darkroom',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ThirtySixPicsApp());
    expect(ThemeController.instance.mode, AppThemeMode.vintage);

    await tester.tap(find.text('YOU'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Darkroom'));
    await tester.pumpAndSettle();

    expect(ThemeController.instance.mode, AppThemeMode.darkroom);

    await tester.tap(find.text('Vintage'));
    await tester.pumpAndSettle();

    expect(ThemeController.instance.mode, AppThemeMode.vintage);
  });
}
