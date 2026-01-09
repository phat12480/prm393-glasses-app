import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/local/db/db_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Catalog')),
      body: FutureBuilder(
        future: db.getAllProducts(),
        builder: (context, snapshot) {
          // 1️⃣ Đang load dữ liệu
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2️⃣ Nếu có lỗi DB → hiện ra để debug
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'DB error:\n${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            );
          }

          // 3️⃣ Có data
          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(
              child: Text('No products', style: TextStyle(fontSize: 16)),
            );
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
                onTap: () {
                  context.go('/product/${p.id}');
                },
              );
            },
          );
        },
      ),
    );
  }
}
