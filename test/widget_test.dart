import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:thirtysix_pics/main.dart';
import 'package:thirtysix_pics/services/roll_store.dart';
import 'package:thirtysix_pics/theme/theme.dart';

void main() {
  late Directory tempRoot;

  setUp(() async {
    tempRoot = Directory.systemTemp.createTempSync('36pics_test');
    await RollStore.instance.load(root: tempRoot);
  });

  tearDown(() {
    ThemeController.instance.setMode(AppThemeMode.vintage);
    tempRoot.deleteSync(recursive: true);
  });

  testWidgets('Empty library invites you to load film', (WidgetTester tester) async {
    await tester.pumpWidget(const ThirtySixPicsApp());

    expect(find.text('Exposures'), findsOneWidget);
    expect(find.text('NO FILM LOADED'), findsOneWidget);
    expect(find.text('Load New Film'), findsOneWidget);
  });

  testWidgets('Library shows the roll being shot with its real count', (WidgetTester tester) async {
    await tester.runAsync(() => RollStore.instance.createRoll('Goa 2025'));
    await tester.pumpWidget(const ThirtySixPicsApp());

    expect(find.text('Goa 2025'), findsOneWidget);
    expect(find.text('36 shots left'), findsOneWidget);
    expect(find.text('Continue Shooting'), findsOneWidget);
  });

  testWidgets('You screen can switch themes and the develop time', (WidgetTester tester) async {
    await tester.pumpWidget(const ThirtySixPicsApp());

    await tester.tap(find.text('YOU'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Darkroom'));
    await tester.pumpAndSettle();
    expect(ThemeController.instance.mode, AppThemeMode.darkroom);

    await tester.tap(find.text('1 week'));
    await tester.pumpAndSettle();
    expect(RollStore.instance.developDelay, const Duration(days: 7));
  });

  group('RollStore', () {
    test('persists photos and survives a reload', () async {
      final store = RollStore.instance;
      final roll = await store.createRoll('Manali');
      final src = File('${tempRoot.path}/shot.jpg')..writeAsBytesSync([1, 2, 3]);

      expect(await store.addPhoto(roll.id, src), isTrue);
      await store.load(root: tempRoot);

      final reloaded = store.roll(roll.id)!;
      expect(reloaded.photos.length, 1);
      expect(store.photoFile(reloaded, reloaded.photos.first).existsSync(), isTrue);
    });

    test('finishing a roll applies the chosen develop delay', () async {
      final store = RollStore.instance;
      await store.setDevelopDelay(const Duration(days: 1));
      final roll = await store.createRoll('Kerala');

      await store.finishRoll(roll.id);

      final done = store.roll(roll.id)!;
      expect(done.isDeveloping, isTrue);
      expect(done.isDeveloped, isFalse);
      expect(done.timeRemaining.inHours, inInclusiveRange(23, 24));
      expect(store.currentRoll, isNull);
    });

    test('a roll becomes developed once its develop time passes', () async {
      final store = RollStore.instance;
      final roll = await store.createRoll('Past');
      roll.completedAt = DateTime.now().subtract(const Duration(days: 2));
      roll.developAt = DateTime.now().subtract(const Duration(days: 1));

      expect(roll.isDeveloped, isTrue);
      expect(roll.timeRemaining, Duration.zero);
    });

    test('deleting a roll removes it and its photos from disk', () async {
      final store = RollStore.instance;
      final roll = await store.createRoll('Doomed');
      final src = File('${tempRoot.path}/shot.jpg')..writeAsBytesSync([1]);
      await store.addPhoto(roll.id, src);
      final photo = store.photoFile(roll, roll.photos.first);
      expect(photo.existsSync(), isTrue);

      await store.deleteRoll(roll.id);

      expect(store.roll(roll.id), isNull);
      expect(photo.existsSync(), isFalse);
      await store.load(root: tempRoot);
      expect(store.roll(roll.id), isNull);
    });

    test('a roll holds at most 36 photos', () async {
      final store = RollStore.instance;
      final roll = await store.createRoll('Full');
      final src = File('${tempRoot.path}/shot.jpg')..writeAsBytesSync([1]);
      for (var i = 0; i < rollSize; i++) {
        expect(await store.addPhoto(roll.id, src), isTrue);
      }
      expect(await store.addPhoto(roll.id, src), isFalse);
    });
  });
}
