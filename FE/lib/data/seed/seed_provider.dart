import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/db/db_provider.dart';
import 'product_seed.dart';

import 'user_seed.dart';

final seedProvider = FutureProvider<void>((ref) async {
  final db = ref.read(dbProvider);
  await seedProducts(db);
  await seedUser(db);
});
