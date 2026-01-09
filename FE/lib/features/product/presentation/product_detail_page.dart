import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/db/db_provider.dart';
import 'package:go_router/go_router.dart';

class ProductDetailPage extends ConsumerWidget {
  final String id;
  const ProductDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Product Detail')),
      body: FutureBuilder(
        future: db.getProductById(int.parse(id)),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final p = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 8),
                Text(p.description),
                const SizedBox(height: 8),
                Text('Giá: ${p.price} VND'),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => context.go('/cart'),
                  child: const Text('Add to Cart'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
