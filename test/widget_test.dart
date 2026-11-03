import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thirtysix_pics/main.dart';
import 'package:image/image.dart' as img;
import 'package:thirtysix_pics/screens/rolls_screen.dart';
import 'package:thirtysix_pics/services/film_stock.dart';
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

  testWidgets('Empty library invites you to load film', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ThirtySixPicsApp());

    expect(find.text('Exposures'), findsOneWidget);
    expect(find.text('NO FILM LOADED'), findsOneWidget);
    expect(find.text('Your rolls will develop here.'), findsOneWidget);
    expect(find.text('Load New Film'), findsOneWidget);
  });

  testWidgets('Library shows the roll being shot with its real count', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() => RollStore.instance.createRoll('Goa 2025'));
    await tester.pumpWidget(const ThirtySixPicsApp());

    expect(find.text('Goa 2025'), findsOneWidget);
    expect(find.text('SHOTS LEFT'), findsOneWidget);
    expect(find.text('0 of 36 exposed'), findsOneWidget);
    expect(find.text('Continue Shooting'), findsOneWidget);
  });

  testWidgets('You screen can switch themes and the develop time', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ThirtySixPicsApp());

    await tester.tap(find.byTooltip('You'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Darkroom'));
    await tester.pumpAndSettle();
    expect(ThemeController.instance.mode, AppThemeMode.darkroom);

    await tester.tap(find.text('1 week'));
    await tester.pumpAndSettle();
    expect(RollStore.instance.developDelay, const Duration(days: 7));
    expect(find.text('The real thing. Maximum anticipation.'), findsOneWidget);
  });

  /// A finished roll without real photo files; enough for list/filter logic.
  Future<Roll> finishedRoll(
    String name, {
    required Duration finishedAgo,
    bool developed = true,
    FilmStock stock = FilmStock.classic,
    int shots = 3,
  }) async {
    final roll = await RollStore.instance.createRoll(name, stock: stock);
    for (var i = 0; i < shots; i++) {
      roll.photos.add('$i.jpg');
      roll.photoStocks.add(stock.name);
    }
    roll.completedAt = DateTime.now().subtract(finishedAgo);
    roll.developAt =
        developed
            ? roll.completedAt!.add(const Duration(seconds: 15))
            : DateTime.now().add(const Duration(hours: 5));
    return roll;
  }

  void usePhoneScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 4800);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  testWidgets('Home previews the latest developed rolls and what is developing', (
    WidgetTester tester,
  ) async {
    usePhoneScreen(tester);
    await tester.runAsync(() async {
      for (var i = 1; i <= 5; i++) {
        await finishedRoll('Trip $i', finishedAgo: Duration(days: 10 - i));
      }
      await finishedRoll('In the tank', finishedAgo: Duration.zero, developed: false);
    });
    await tester.pumpWidget(const ThirtySixPicsApp());

    expect(find.text('Developing'), findsOneWidget);
    expect(find.text('In the tank'), findsOneWidget);
    expect(find.text('Trip 5'), findsOneWidget);
    expect(find.text('Trip 2'), findsOneWidget);
    expect(find.text('Trip 1'), findsNothing); // only the latest four
    expect(find.text('See all 6 ›'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('See all on Home opens the Rolls archive', (
    WidgetTester tester,
  ) async {
    usePhoneScreen(tester);
    await tester.runAsync(() => finishedRoll('Trip', finishedAgo: const Duration(days: 1)));
    await tester.pumpWidget(const ThirtySixPicsApp());

    await tester.tap(find.text('See all 1 ›'));
    await tester.pump();

    expect(find.text('ARCHIVE'), findsOneWidget);
    expect(find.text('1 roll · 3 photos'), findsOneWidget);
  });

  testWidgets('Rolls tab filters by status and by film stock', (
    WidgetTester tester,
  ) async {
    usePhoneScreen(tester);
    await tester.runAsync(() async {
      await finishedRoll('Goa', finishedAgo: const Duration(days: 3));
      await finishedRoll('Night walk', finishedAgo: const Duration(days: 2), stock: FilmStock.noir);
      await finishedRoll('Waiting', finishedAgo: Duration.zero, developed: false);
    });
    await tester.pumpWidget(const ThirtySixPicsApp());
    await tester.tap(find.text('ROLLS'));
    await tester.pump();

    expect(find.text('3 rolls · 9 photos'), findsOneWidget);
    expect(find.text('All 3'), findsOneWidget);
    expect(find.text('Developing 1'), findsOneWidget);
    expect(find.text('Ready 2'), findsOneWidget);
    expect(find.text('Goa'), findsOneWidget);

    await tester.tap(find.text('Developing 1'));
    await tester.pump();
    expect(find.text('Waiting'), findsOneWidget);
    expect(find.text('Goa'), findsNothing);
    expect(find.text('1 of 3'), findsOneWidget);

    await tester.tap(find.text('Ready 2'));
    await tester.pump();
    await tester.tap(find.text('Noir'));
    await tester.pump();
    expect(find.text('Night walk'), findsOneWidget);
    expect(find.text('Goa'), findsNothing);

    await tester.tap(find.text('Developing 1'));
    await tester.pump();
    expect(find.text('No rolls match.'), findsOneWidget);
    await tester.tap(find.text('Clear filters'));
    await tester.pump();
    expect(find.text('Goa'), findsOneWidget);
    expect(find.text('Waiting'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Rolls tab hides the stock filter until two stocks are in use', (
    WidgetTester tester,
  ) async {
    usePhoneScreen(tester);
    await tester.runAsync(() => finishedRoll('Goa', finishedAgo: const Duration(days: 1)));
    await tester.pumpWidget(const ThirtySixPicsApp());
    await tester.tap(find.text('ROLLS'));
    await tester.pump();

    expect(find.text('Any stock'), findsNothing);
  });

  testWidgets('Rolls tab explains itself when there are no rolls', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ThirtySixPicsApp());
    await tester.tap(find.text('ROLLS'));
    await tester.pump();

    expect(find.text('Tap the shutter to load your first roll.'), findsOneWidget);
    expect(find.text('0 rolls · 0 photos'), findsOneWidget);
  });

  group('filterRolls', () {
    Roll roll(String id, int daysAgo, {FilmStock stock = FilmStock.classic, bool developed = true}) {
      final done = DateTime.now().subtract(Duration(days: daysAgo));
      return Roll(
        id: id,
        name: id,
        createdAt: done,
        stock: stock,
        photos: ['a.jpg'],
        photoStocks: [stock.name],
        completedAt: done,
        developAt: developed ? done.add(const Duration(seconds: 15)) : DateTime.now().add(const Duration(hours: 1)),
      );
    }

    final rolls = [
      roll('a', 5),
      roll('b', 3, stock: FilmStock.noir),
      roll('c', 1, developed: false),
      Roll(id: 'shooting', name: 'shooting', createdAt: DateTime.now()),
    ];

    List<String> ids(List<Roll> r) => r.map((e) => e.id).toList();

    test('lists finished rolls newest first and skips the one being shot', () {
      expect(ids(filterRolls(rolls)), ['c', 'b', 'a']);
      expect(ids(filterRolls(rolls, newestFirst: false)), ['a', 'b', 'c']);
    });

    test('filters by developing or ready', () {
      expect(ids(filterRolls(rolls, status: RollStatus.developing)), ['c']);
      expect(ids(filterRolls(rolls, status: RollStatus.ready)), ['b', 'a']);
    });

    test('filters by film stock, matching any frame shot on it', () {
      expect(ids(filterRolls(rolls, stock: FilmStock.noir)), ['b']);
      final mixed = roll('m', 2)..photoStocks.add(FilmStock.noir.name);
      expect(ids(filterRolls([...rolls, mixed], stock: FilmStock.noir)), ['m', 'b']);
    });
  });

  group('Countdown formatting', () {
    test('splits long waits into days and hours', () {
      expect(countdownParts(const Duration(days: 2, hours: 14, minutes: 32)), ('2d', '14 hrs 32 min'));
    });

    test('shows minutes and seconds for short waits', () {
      expect(countdownParts(const Duration(minutes: 3, seconds: 7)), ('3:07', 'min : sec'));
    });

    test('names the weekday for far-off reveals and the time for near ones', () {
      final now = DateTime(2026, 11, 1, 9, 0);
      expect(readyOnLabel(DateTime(2026, 11, 7, 9, 0), now: now), 'Saturday, Nov 7');
      expect(readyOnLabel(DateTime(2026, 11, 1, 21, 41), now: now), '9:41 PM');
    });
  });

  group('Film stocks', () {
    final colorful = img.Image(width: 8, height: 8);
    for (final p in colorful) {
      p
        ..r = 220
        ..g = 90
        ..b = 40;
    }
    final jpeg = Uint8List.fromList(img.encodeJpg(colorful, quality: 95));

    test('Noir turns a colour photo black and white', () {
      final out = img.decodeJpg(bakeFilmStock(jpeg, FilmStock.noir))!;
      final p = out.getPixel(4, 4);
      expect((p.r - p.g).abs(), lessThan(6));
      expect((p.g - p.b).abs(), lessThan(6));
    });

    test("Faded '70s lifts the blacks and warms the image", () {
      final dark = img.Image(width: 8, height: 8);
      for (final p in dark) {
        p
          ..r = 0
          ..g = 0
          ..b = 0;
      }
      final out =
          img.decodeJpg(
            bakeFilmStock(
              Uint8List.fromList(img.encodeJpg(dark)),
              FilmStock.faded70s,
            ),
          )!;
      final p = out.getPixel(4, 4);
      expect(p.r, greaterThan(35));
      expect(p.r, greaterThan(p.b));
    });

    test("Faded '70s visibly shifts a normal colour photo", () {
      final out = img.decodeJpg(bakeFilmStock(jpeg, FilmStock.faded70s))!;
      final p = out.getPixel(4, 4);
      final before = img.decodeJpg(jpeg)!.getPixel(4, 4);
      expect(
        (p.r - before.r).abs() +
            (p.g - before.g).abs() +
            (p.b - before.b).abs(),
        greaterThan(60),
      );
    });

    test('Classic leaves the photo untouched', () {
      expect(bakeFilmStock(jpeg, FilmStock.classic), same(jpeg));
    });
  });

  group('RollStore', () {
    test("remembers a roll's film stock across a reload", () async {
      final store = RollStore.instance;
      final roll = await store.createRoll('Noir trip', stock: FilmStock.noir);

      await store.load(root: tempRoot);

      expect(store.roll(roll.id)!.stock, FilmStock.noir);
    });

    test('saves the chosen theme and restores it on launch', () async {
      ThemeController.instance.setMode(AppThemeMode.darkroom);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      final saved = File('${tempRoot.path}/store.json').readAsStringSync();
      expect(saved, contains('"themeMode":"darkroom"'));

      ThemeController.instance.setMode(AppThemeMode.vintage);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      File('${tempRoot.path}/store.json').writeAsStringSync(saved);
      await RollStore.instance.load(root: tempRoot);

      expect(ThemeController.instance.mode, AppThemeMode.darkroom);
    });

    test('persists photos and survives a reload', () async {
      final store = RollStore.instance;
      final roll = await store.createRoll('Manali');
      final src = File('${tempRoot.path}/shot.jpg')
        ..writeAsBytesSync([1, 2, 3]);

      expect(await store.addPhoto(roll.id, src), isTrue);
      await store.load(root: tempRoot);

      final reloaded = store.roll(roll.id)!;
      expect(reloaded.photos.length, 1);
      expect(
        store.photoFile(reloaded, reloaded.photos.first).existsSync(),
        isTrue,
      );
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

    test(
      'abandoning develops what was shot in 5 seconds, ignoring the setting',
      () async {
        final store = RollStore.instance;
        await store.setDevelopDelay(const Duration(days: 7));
        final roll = await store.createRoll('Cut short');
        final src = File('${tempRoot.path}/shot.jpg')..writeAsBytesSync([1]);
        await store.addPhoto(roll.id, src);
        await store.addPhoto(roll.id, src);

        await store.abandonRoll(roll.id);

        final done = store.roll(roll.id)!;
        expect(done.photos.length, 2);
        expect(done.isDeveloping, isTrue);
        expect(done.timeRemaining.inSeconds, inInclusiveRange(3, 5));
        expect(store.currentRoll, isNull);
      },
    );

    test('abandoning an empty roll discards it', () async {
      final store = RollStore.instance;
      final roll = await store.createRoll('Never shot');

      await store.abandonRoll(roll.id);

      expect(store.roll(roll.id), isNull);
      expect(store.currentRoll, isNull);
    });

    test(
      'switching stock mid-roll is remembered per photo and labelled MIXED',
      () async {
        final store = RollStore.instance;
        final roll = await store.createRoll('Mixed');
        final src = File('${tempRoot.path}/shot.jpg')..writeAsBytesSync([1]);

        await store.addPhoto(roll.id, src);
        expect(roll.stockLabel, isNull);
        await store.setStock(roll.id, FilmStock.noir);
        await store.addPhoto(roll.id, src);
        expect(roll.stockLabel, 'MIXED');

        await store.load(root: tempRoot);
        final reloaded = store.roll(roll.id)!;
        expect(reloaded.stock, FilmStock.noir);
        expect(reloaded.photoStocks, ['classic', 'noir']);
      },
    );

    test('a roll saved by an older version can still take photos', () async {
      final now = DateTime.now().toIso8601String();
      File('${tempRoot.path}/store.json').writeAsStringSync(
        '{"developDelaySeconds":15,"rolls":[{"id":"old","name":"Old roll","createdAt":"$now",'
        '"stock":"noir","photos":["a.jpg","b.jpg"],"completedAt":null,"developAt":null}]}',
      );
      final store = RollStore.instance;
      await store.load(root: tempRoot);
      final src = File('${tempRoot.path}/shot.jpg')..writeAsBytesSync([1]);

      expect(await store.addPhoto('old', src), isTrue);

      final roll = store.roll('old')!;
      expect(roll.photos.length, 3);
      expect(roll.photoStocks, ['noir', 'noir', 'noir']);
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
