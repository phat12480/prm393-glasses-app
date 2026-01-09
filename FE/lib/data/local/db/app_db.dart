import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_db.g.dart'; // 🔴 BẮT BUỘC

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get email => text().unique()();
  TextColumn get password => text()();
  TextColumn get fullName => text()();
}

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  IntColumn get price => integer()();
  TextColumn get image => text()(); // asset hoặc url (mock)
}

@DriftDatabase(tables: [Users, Products])
class AppDb extends _$AppDb {
  AppDb() : super(driftDatabase(name: 'glasses_shop_db'));

  @override
  int get schemaVersion => 1;

  Future<List<Product>> getAllProducts() => select(products).get();

  Future<Product?> getProductById(int id) {
    return (select(products)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  // REGISTER
  Future<int> insertUser(UsersCompanion user) {
    return into(users).insert(user);
  }

  // LOGIN
  Future<User?> login(String email, String password) {
    return (select(users)
          ..where((u) => u.email.equals(email) & u.password.equals(password)))
        .getSingleOrNull();
  }
}
