import 'package:hive_flutter/hive_flutter.dart';

import '../models/ranking.dart';
import '../models/shop.dart';
import '../models/visit.dart';

class HiveService {
  HiveService({
    required Box<Shop> shopsBox,
    required Box<Visit> visitsBox,
    required Box<Ranking> rankingsBox,
  }) : this._internal(shopsBox, visitsBox, rankingsBox);

  HiveService._internal(this._shopsBox, this._visitsBox, this._rankingsBox);

  static const shopsBoxName = 'shops';
  static const visitsBoxName = 'visits';
  static const rankingsBoxName = 'rankings';

  final Box<Shop> _shopsBox;
  final Box<Visit> _visitsBox;
  final Box<Ranking> _rankingsBox;

  static Future<HiveService> initialize() async {
    await Hive.initFlutter();
    registerAdapters();

    final shopsBox = await Hive.openBox<Shop>(shopsBoxName);
    final visitsBox = await Hive.openBox<Visit>(visitsBoxName);
    final rankingsBox = await Hive.openBox<Ranking>(rankingsBoxName);

    return HiveService(
      shopsBox: shopsBox,
      visitsBox: visitsBox,
      rankingsBox: rankingsBox,
    );
  }

  static void registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ShopAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(VisitAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(RankingAdapter());
    }
  }

  Future<void> addShop(Shop shop) => _shopsBox.put(shop.id, shop);

  List<Shop> getAllShops() => _shopsBox.values.toList(growable: false);

  Future<void> addVisit(Visit visit) => _visitsBox.put(visit.id, visit);

  List<Visit> getVisitsForShop(String shopId) => _visitsBox.values
      .where((visit) => visit.shopId == shopId)
      .toList(growable: false);

  Future<void> deleteShop(String shopId) async {
    await _shopsBox.delete(shopId);

    final visitIds = _visitsBox.values
        .where((visit) => visit.shopId == shopId)
        .map((visit) => visit.id)
        .toList(growable: false);
    await _visitsBox.deleteAll(visitIds);

    final remainingRankings = getRankingList()
        .where((ranking) => ranking.shopId != shopId)
        .toList(growable: false);
    final reindexedRankings = [
      for (var index = 0; index < remainingRankings.length; index++)
        Ranking(
          shopId: remainingRankings[index].shopId,
          rankPosition: index,
          score: remainingRankings[index].score,
        ),
    ];
    await updateRankingList(reindexedRankings);
  }

  List<Ranking> getRankingList() {
    final rankings = _rankingsBox.values.toList();
    rankings.sort((a, b) => a.rankPosition.compareTo(b.rankPosition));
    return List<Ranking>.unmodifiable(rankings);
  }

  Future<void> updateRankingList(List<Ranking> rankings) async {
    await _rankingsBox.clear();
    for (final ranking in rankings) {
      await _rankingsBox.put(ranking.shopId, ranking);
    }
  }
}
