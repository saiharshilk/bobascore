import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/shop.dart';
import '../providers/shops_provider.dart';
import 'add_shop_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _openAddShop(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AddShopScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shops = ref.watch(shopsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('BobaScore'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Want to Try'),
              Tab(text: 'Ranked'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ShopList(
              shops: shops
                  .where((shop) => shop.status == ShopStatus.wantToTry)
                  .toList(growable: false),
              emptyTitle: 'Your next boba adventure starts here',
              emptyMessage: 'Add a shop to start building your list.',
            ),
            _ShopList(
              shops: shops
                  .where((shop) => shop.status == ShopStatus.ranked)
                  .toList(growable: false),
              emptyTitle: 'No ranked shops yet',
              emptyMessage: 'Your ranked shops will appear here after a visit.',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openAddShop(context),
          icon: const Icon(Icons.add),
          label: const Text('Add shop'),
        ),
      ),
    );
  }
}

class _ShopList extends StatelessWidget {
  const _ShopList({
    required this.shops,
    required this.emptyTitle,
    required this.emptyMessage,
  });

  final List<Shop> shops;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (shops.isEmpty) {
      return _EmptyShopState(title: emptyTitle, message: emptyMessage);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: shops.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final shop = shops[index];
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              foregroundColor: Theme.of(
                context,
              ).colorScheme.onSecondaryContainer,
              child: const Icon(Icons.local_cafe_outlined),
            ),
            title: Text(
              shop.name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: shop.address.isEmpty ? null : Text(shop.address),
          ),
        );
      },
    );
  }
}

class _EmptyShopState extends StatelessWidget {
  const _EmptyShopState({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_cafe_rounded, size: 64, color: colors.primary),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
