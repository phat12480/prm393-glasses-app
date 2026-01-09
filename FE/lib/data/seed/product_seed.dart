import '../local/db/app_db.dart';

Future<void> seedProducts(AppDb db) async {
  final existing = await db.getAllProducts();
  if (existing.isNotEmpty) return;

  await db.batch((batch) {
    batch.insertAll(db.products, [
      ProductsCompanion.insert(
        name: 'Gọng kính Classic',
        description: 'Gọng kính nhựa cổ điển',
        price: 300000,
        image: 'classic.png',
      ),
      ProductsCompanion.insert(
        name: 'Kính mát Ray Style',
        description: 'Kính mát chống UV',
        price: 500000,
        image: 'ray.png',
      ),
      ProductsCompanion.insert(
        name: 'Gọng titan siêu nhẹ',
        description: 'Gọng cao cấp, siêu nhẹ',
        price: 1200000,
        image: 'titan.png',
      ),
    ]);
  });
}
