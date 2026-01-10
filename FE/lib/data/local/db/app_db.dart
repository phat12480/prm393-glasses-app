import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_db.g.dart';

// ===================== TABLES =====================

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
  TextColumn get image => text()();
}

// ORDERS
class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer()(); // MVP: chỉ lưu userId (chưa FK)

  TextColumn get orderDate => text()(); // ISO String
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get paymentMethod => text().withDefault(const Constant('COD'))();

  IntColumn get totalPrice => integer()();
}

// ORDER_ITEMS
class OrderItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer()();

  TextColumn get productType =>
      text().withDefault(const Constant('ready'))(); // ready|build

  IntColumn get productId => integer().nullable()(); // ready dùng
  IntColumn get frameId => integer().nullable()(); // build để sau
  IntColumn get lensId => integer().nullable()(); // build để sau

  IntColumn get quantity => integer().withDefault(const Constant(1))();
  IntColumn get unitPrice => integer()();
}

// ===================== DB =====================

@DriftDatabase(tables: [Users, Products, Orders, OrderItems])
class AppDb extends _$AppDb {
  AppDb() : super(driftDatabase(name: 'glasses_shop_db'));

  @override
  int get schemaVersion => 2;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // MVP nhanh: xoá DB cũ và tạo lại theo schema mới
      // Lưu ý: tên bảng drift mặc định là dạng snake_case
      await m.deleteTable('order_items');
      await m.deleteTable('orders');
      await m.deleteTable('products');
      await m.deleteTable('users');

      await m.createAll();
    },
  );

  // PRODUCTS
  Future<List<Product>> getAllProducts() => select(products).get();

  Future<Product?> getProductById(int id) {
    return (select(products)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  // AUTH
  Future<int> insertUser(UsersCompanion user) => into(users).insert(user);

  Future<User?> login(String email, String password) {
    return (select(users)
          ..where((u) => u.email.equals(email) & u.password.equals(password)))
        .getSingleOrNull();
  }

  // ORDERS
  // ORDERS
  Future<int> createOrder({
    required int userId,
    required int totalPrice,
    String status = 'pending',
    String paymentMethod = 'COD',
  }) {
    final now = DateTime.now().toIso8601String();

    return into(orders).insert(
      OrdersCompanion(
        userId: Value(userId),
        orderDate: Value(now),
        status: Value(status),
        paymentMethod: Value(paymentMethod),
        totalPrice: Value(totalPrice),
      ),
    );
  }

  Future<int> addOrderItem({
    required int orderId,
    String productType = 'ready',
    int? productId,
    int? frameId,
    int? lensId,
    required int quantity,
    required int unitPrice,
  }) {
    return into(orderItems).insert(
      OrderItemsCompanion(
        orderId: Value(orderId),
        productType: Value(productType),
        productId: Value(productId),
        frameId: Value(frameId),
        lensId: Value(lensId),
        quantity: Value(quantity),
        unitPrice: Value(unitPrice),
      ),
    );
  }

  Future<List<Order>> getOrdersByUser(int userId) {
    return (select(orders)
          ..where((o) => o.userId.equals(userId))
          ..orderBy([(o) => OrderingTerm.desc(o.id)]))
        .get();
  }

  Future<List<OrderItem>> getOrderItemsByOrderId(int orderId) {
    return (select(orderItems)..where((i) => i.orderId.equals(orderId))).get();
  }
}
