import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:boba_score/models/ranking.dart';
import 'package:boba_score/models/shop.dart';
import 'package:boba_score/models/visit.dart';
import 'package:boba_score/services/hive_service.dart';

void main() {
  late Directory hiveDirectory;
  late Box<Shop> shopsBox;
  late Box<Visit> visitsBox;
  late Box<Ranking> rankingsBox;
  late HiveService service;

  setUp(() async {
    hiveDirectory = await Directory.systemTemp.createTemp('boba_score_test_');
    Hive.init(hiveDirectory.path);
    HiveService.registerAdapters();

    shopsBox = await Hive.openBox<Shop>('shops_test');
    visitsBox = await Hive.openBox<Visit>('visits_test');
    rankingsBox = await Hive.openBox<Ranking>('rankings_test');
    service = HiveService(
      shopsBox: shopsBox,
      visitsBox: visitsBox,
      rankingsBox: rankingsBox,
    );
  });

  tearDown(() async {
    await shopsBox.close();
    await visitsBox.close();
    await rankingsBox.close();
    await hiveDirectory.delete(recursive: true);
  });

  test('persists all model fields through Hive adapters', () async {
    final addedDate = DateTime.utc(2026, 8, 2, 12, 30);
    final shop = Shop(
      id: 'shop-1',
      name: 'Taro House',
      address: '123 Tea Street',
      latitude: 37.7749,
      longitude: -122.4194,
      tags: ['taro', 'brown sugar'],
      dateAdded: addedDate,
      status: ShopStatus.ranked,
    );
    final visit = Visit(
      id: 'visit-1',
      shopId: shop.id,
      date: addedDate,
      drinkOrdered: 'Taro milk tea',
      price: 6.5,
      notes: 'Less ice',
      photoPath: '/tmp/taro.jpg',
    );
    const ranking = Ranking(shopId: 'shop-1', rankPosition: 0, score: 9.25);

    await shopsBox.put(shop.id, shop);
    await visitsBox.put(visit.id, visit);
    await rankingsBox.put(ranking.shopId, ranking);
    await shopsBox.flush();
    await visitsBox.flush();
    await rankingsBox.flush();

    final storedShop = shopsBox.get(shop.id)!;
    final storedVisit = visitsBox.get(visit.id)!;
    final storedRanking = rankingsBox.get(ranking.shopId)!;

    expect(storedShop.id, shop.id);
    expect(storedShop.tags, shop.tags);
    expect(storedShop.status, ShopStatus.ranked);
    expect(storedShop.dateAdded, addedDate);
    expect(storedVisit.price, 6.5);
    expect(storedVisit.notes, 'Less ice');
    expect(storedVisit.photoPath, '/tmp/taro.jpg');
    expect(storedRanking.rankPosition, 0);
    expect(storedRanking.score, 9.25);
  });

  test('CRUD operations manage shops, visits, and ordered rankings', () async {
    final firstShop = Shop(
      id: 'shop-1',
      name: 'First Shop',
      address: '1 Tea Street',
      latitude: 1,
      longitude: 2,
    );
    final secondShop = Shop(
      id: 'shop-2',
      name: 'Second Shop',
      address: '2 Tea Street',
      latitude: 3,
      longitude: 4,
    );
    final visit = Visit(
      id: 'visit-1',
      shopId: firstShop.id,
      date: DateTime.utc(2026, 8, 2),
      drinkOrdered: 'Fruit tea',
    );

    await service.addShop(firstShop);
    await service.addShop(secondShop);
    await service.addVisit(visit);
    await service.updateRankingList([
      const Ranking(shopId: 'shop-2', rankPosition: 1, score: 7),
      const Ranking(shopId: 'shop-1', rankPosition: 0, score: 9),
    ]);

    expect(
      service.getAllShops().map((shop) => shop.id),
      containsAll(<String>['shop-1', 'shop-2']),
    );
    expect(service.getVisitsForShop('shop-1').single.id, 'visit-1');
    expect(service.getRankingList().map((ranking) => ranking.shopId), [
      'shop-1',
      'shop-2',
    ]);

    await service.deleteShop('shop-1');

    expect(service.getAllShops().map((shop) => shop.id), ['shop-2']);
    expect(service.getVisitsForShop('shop-1'), isEmpty);
    expect(service.getRankingList().map((ranking) => ranking.shopId), [
      'shop-2',
    ]);
  });

  test('nullable visit fields round-trip as null', () async {
    final visit = Visit(
      id: 'visit-null',
      shopId: 'shop-1',
      date: DateTime.utc(2026, 8, 2),
      drinkOrdered: 'Classic milk tea',
    );

    await visitsBox.put(visit.id, visit);
    final storedVisit = visitsBox.get(visit.id)!;

    expect(storedVisit.price, isNull);
    expect(storedVisit.notes, isNull);
    expect(storedVisit.photoPath, isNull);
  });
}
