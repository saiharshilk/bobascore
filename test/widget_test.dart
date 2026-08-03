import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:boba_score/main.dart';
import 'package:boba_score/models/ranking.dart';
import 'package:boba_score/models/shop.dart';
import 'package:boba_score/models/visit.dart';
import 'package:boba_score/providers/hive_service_provider.dart';
import 'package:boba_score/services/hive_service.dart';

void main() {
  late Box<Shop> shopsBox;
  late Box<Visit> visitsBox;
  late Box<Ranking> rankingsBox;
  late HiveService service;

  setUpAll(() async {
    HiveService.registerAdapters();
    shopsBox = await Hive.openBox<Shop>('ui_shops', bytes: Uint8List(0));
    visitsBox = await Hive.openBox<Visit>('ui_visits', bytes: Uint8List(0));
    rankingsBox = await Hive.openBox<Ranking>(
      'ui_rankings',
      bytes: Uint8List(0),
    );
    service = HiveService(
      shopsBox: shopsBox,
      visitsBox: visitsBox,
      rankingsBox: rankingsBox,
    );
  });

  setUp(() async {
    await shopsBox.clear();
    await visitsBox.clear();
    await rankingsBox.clear();
  });

  tearDownAll(() async {
    await shopsBox.close();
    await visitsBox.close();
    await rankingsBox.close();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [hiveServiceProvider.overrideWithValue(service)],
        child: const BobaScoreApp(),
      ),
    );
  }

  testWidgets('home screen shows the two shop status tabs', (tester) async {
    await pumpApp(tester);

    expect(find.text('Want to Try'), findsOneWidget);
    expect(find.text('Ranked'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Your next boba adventure starts here'), findsOneWidget);
  });

  testWidgets('user can add a shop and see it in Want to Try', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Add a new shop'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('shopNameField')),
      'Taro House',
    );
    await tester.enterText(
      find.byKey(const Key('addressField')),
      '123 Tea Street',
    );
    await tester.tap(find.text('taro'));
    await tester.enterText(find.byKey(const Key('customTagField')), 'pudding');
    await tester.tap(find.byTooltip('Add custom tag'));
    await tester.tap(find.text('Save shop'));
    await tester.pumpAndSettle(
      const Duration(milliseconds: 50),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 2),
    );

    expect(find.byKey(const Key('shopNameField')), findsNothing);
    expect(find.text('Taro House'), findsOneWidget);
    expect(find.text('123 Tea Street'), findsOneWidget);
    expect(service.getAllShops(), hasLength(1));
    expect(service.getAllShops().single.status, ShopStatus.wantToTry);
    expect(
      service.getAllShops().single.tags,
      containsAll(<String>['taro', 'pudding']),
    );
  });
}
