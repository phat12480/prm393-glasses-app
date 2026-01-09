import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/local/db/db_provider.dart';
import '../../../data/seed/seed_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seedAsync = ref.watch(seedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Catalog')),
      body: seedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Seed error:\n$e',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
        data: (_) => _CatalogBody(),
      ),
    );
  }
}

class _CatalogBody extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);

    return FutureBuilder(
      future: db.getAllProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'DB error:\n${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final products = snapshot.data ?? [];
        if (products.isEmpty) {
          return const Center(child: Text('No products'));
        }

        return ListView.separated(
          itemCount: products.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final p = products[index];
            return ListTile(
              title: Text(p.name),
              subtitle: Text('${p.price} VND'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/product/${p.id}'),
            );
          },
        );
      },
    );
  }
}
