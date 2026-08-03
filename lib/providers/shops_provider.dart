import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/shop.dart';
import 'hive_service_provider.dart';

final shopsProvider = NotifierProvider<ShopsNotifier, List<Shop>>(
  ShopsNotifier.new,
);

class ShopsNotifier extends Notifier<List<Shop>> {
  @override
  List<Shop> build() {
    return ref.watch(hiveServiceProvider).getAllShops();
  }

  Future<void> addShop(Shop shop) async {
    await ref.read(hiveServiceProvider).addShop(shop);
    state = ref.read(hiveServiceProvider).getAllShops();
  }
}
