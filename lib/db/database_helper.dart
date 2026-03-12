import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/user.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dolleyes_store.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE users (
      user_id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE,
      password TEXT,
      full_name TEXT,
      email TEXT UNIQUE,
      phone TEXT,
      address TEXT,
      role TEXT,
      status TEXT,
      created_at TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE categories (
      category_id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      type TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE products (
      product_id INTEGER PRIMARY KEY AUTOINCREMENT,
      category_id INTEGER,
      name TEXT NOT NULL,
      description TEXT,
      price REAL NOT NULL,
      image_url TEXT,
      stock INTEGER NOT NULL,
      status TEXT,
      specs TEXT,
      FOREIGN KEY (category_id) REFERENCES categories (category_id)
    )
    ''');

    await db.execute('''
    CREATE TABLE orders (
      order_id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      order_date TEXT,
      total_amount REAL,
      status TEXT,
      payment_method TEXT,
      created_at TEXT,
      FOREIGN KEY (user_id) REFERENCES users (user_id)
    )
    ''');

    await db.execute('''
    CREATE TABLE order_items (
      order_item_id INTEGER PRIMARY KEY AUTOINCREMENT,
      order_id INTEGER,
      product_id INTEGER,
      lens_product_id INTEGER,
      selected_color TEXT,
      quantity INTEGER,
      price REAL,
      FOREIGN KEY (order_id) REFERENCES orders (order_id),
      FOREIGN KEY (product_id) REFERENCES products (product_id),
      FOREIGN KEY (lens_product_id) REFERENCES products (product_id)
    )
    ''');

    await _seedData(db);
  }

  Future _seedData(Database db) async {
    int guestUserId = await db.insert('users', {
      'username': 'guest',
      'password': _hashPassword('123'),
      'full_name': 'Guest',
      'email': 'guest@gmail.com',
      'phone': '',
      'address': '',
      'role': 'CUSTOMER',
      'status': 'ACTIVE',
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.insert('users', {
      'username': 'admin',
      'password': _hashPassword('123'),
      'full_name': 'Admin',
      'email': 'admin@gmail.com',
      'phone': '',
      'address': '',
      'role': 'ADMIN',
      'status': 'ACTIVE',
      'created_at': DateTime.now().toIso8601String(),
    });

    int catFrame = await db.insert('categories', {
      'name': 'Gọng Thời Trang',
      'type': 'FRAME'
    });

    int catLens = await db.insert('categories', {
      'name': 'Tròng Thuốc',
      'type': 'LENS'
    });

    int catReady = await db.insert('categories', {
      'name': 'Kính Râm',
      'type': 'READY'
    });

    int frame1Id = await db.insert('products', {
      'category_id': catFrame,
      'name': 'Gọng Titan Tròn Cổ Điển',
      'description':
      'Thiết kế bo tròn thanh lịch, chất liệu Titanium siêu nhẹ không gây vết hằn trên sống mũi.',
      'price': 550000,
      'image_url':
      'https://images.unsplash.com/photo-1591076482161-42ce6da69f67?q=80&w=1000&auto=format&fit=crop',
      'stock': 100,
      'status': 'ACTIVE',
      'specs':
      '{"colors": ["Đen", "Bạc", "Vàng Hồng"], "material": "Titanium", "shape": "Round"}'
    });

    int frame2Id = await db.insert('products', {
      'category_id': catFrame,
      'name': 'Gọng Nhựa Dẻo TR90',
      'description':
      'Độ đàn hồi cao, bẻ cong không gãy. Phù hợp cho các bạn học sinh, sinh viên năng động.',
      'price': 250000,
      'image_url':
      'https://images.unsplash.com/photo-1582142407894-ec85a1260a46?q=80&w=1000&auto=format&fit=crop',
      'stock': 200,
      'status': 'ACTIVE',
      'specs':
      '{"colors": ["Trong Suốt", "Đen Nhám", "Xanh Navy"], "material": "TR90", "shape": "Square"}'
    });

    int frame3Id = await db.insert('products', {
      'category_id': catFrame,
      'name': 'Gọng Mắt Mèo Cá Tính',
      'description':
      'Tôn lên đường nét khuôn mặt, giúp gương mặt trở nên sắc sảo và cuốn hút hơn.',
      'price': 450000,
      'image_url': '',
      'stock': 50,
      'status': 'ACTIVE',
      'specs':
      '{"colors": ["Đồi Mồi", "Đen Bóng", "Đỏ Rượu"], "material": "Acetate", "shape": "Cat-eye"}'
    });

    int lens1Id = await db.insert('products', {
      'category_id': catLens,
      'name': 'Tròng Chống Ánh Sáng Xanh',
      'description':
      'Bảo vệ mắt khỏi tia sáng xanh có hại từ màn hình máy tính, điện thoại. Giảm nhức mỏi mắt.',
      'price': 300000,
      'image_url':
      'https://images.unsplash.com/photo-1556306535-0f09a536f0b1?q=80&w=1000&auto=format&fit=crop',
      'stock': 500,
      'status': 'ACTIVE',
      'specs': '{"feature": "BlueCut", "index": "1.56"}'
    });

    int lens2Id = await db.insert('products', {
      'category_id': catLens,
      'name': 'Tròng Đổi Màu Đi Nắng',
      'description':
      'Tự động chuyển sang màu sậm khi ra ngoài trời nắng và trong suốt trở lại khi vào nhà.',
      'price': 650000,
      'image_url': '',
      'stock': 150,
      'status': 'ACTIVE',
      'specs': '{"feature": "Photochromic", "index": "1.61"}'
    });

    int lens3Id = await db.insert('products', {
      'category_id': catLens,
      'name': 'Tròng Siêu Mỏng Chống Xước',
      'description':
      'Dành cho người độ cận cao. Tròng mỏng nhẹ hơn 30% so với tròng thường, phủ lớp chống xước cao cấp.',
      'price': 950000,
      'image_url': '',
      'stock': 80,
      'status': 'ACTIVE',
      'specs': '{"feature": "Anti-scratch, Super Thin", "index": "1.67"}'
    });

    int ready1Id = await db.insert('products', {
      'category_id': catReady,
      'name': 'Kính Râm Phân Cực Polarized',
      'description':
      'Chống chói lóa tối đa khi lái xe hoặc đi biển. Bảo vệ mắt tuyệt đối với chuẩn UV400.',
      'price': 750000,
      'image_url':
      'https://images.unsplash.com/photo-1511499767150-a48a237f0083?q=80&w=1000&auto=format&fit=crop',
      'stock': 60,
      'status': 'ACTIVE',
      'specs': '{"colors": ["Đen Khói", "Xanh Rêu"], "uv": "UV400 Polarized"}'
    });

    int ready2Id = await db.insert('products', {
      'category_id': catReady,
      'name': 'Kính Mát Bản To Thời Trang',
      'description':
      'Phụ kiện không thể thiếu cho các tín đồ thời trang. Thiết kế oversize giúp che khuyết điểm hoàn hảo.',
      'price': 350000,
      'image_url':
      'https://images.unsplash.com/photo-1574258495973-f010dfbb5371?q=80&w=1000&auto=format&fit=crop',
      'stock': 120,
      'status': 'ACTIVE',
      'specs': '{"colors": ["Trắng Sữa", "Đen", "Be"], "uv": "UV400"}'
    });

    final now = DateTime.now();

    int order1Id = await db.insert('orders', {
      'user_id': guestUserId,
      'order_date': now.toIso8601String(),
      'total_amount': 1600000,
      'status': 'PENDING',
      'payment_method': 'COD',
      'created_at': now.toIso8601String(),
    });

    await db.insert('order_items', {
      'order_id': order1Id,
      'product_id': frame1Id,
      'lens_product_id': lens1Id,
      'selected_color': 'Đen',
      'quantity': 1,
      'price': 850000,
    });

    await db.insert('order_items', {
      'order_id': order1Id,
      'product_id': ready1Id,
      'lens_product_id': null,
      'selected_color': 'Đen Khói',
      'quantity': 1,
      'price': 750000,
    });

    final date2 = now.subtract(const Duration(days: 1));
    int order2Id = await db.insert('orders', {
      'user_id': guestUserId,
      'order_date': date2.toIso8601String(),
      'total_amount': 900000,
      'status': 'PENDING',
      'payment_method': 'COD',
      'created_at': date2.toIso8601String(),
    });

    await db.insert('order_items', {
      'order_id': order2Id,
      'product_id': frame2Id,
      'lens_product_id': lens2Id,
      'selected_color': 'Xanh Navy',
      'quantity': 1,
      'price': 900000,
    });

    final date3 = now.subtract(const Duration(days: 2));
    int order3Id = await db.insert('orders', {
      'user_id': guestUserId,
      'order_date': date3.toIso8601String(),
      'total_amount': 700000,
      'status': 'COMPLETED',
      'payment_method': 'COD',
      'created_at': date3.toIso8601String(),
    });

    await db.insert('order_items', {
      'order_id': order3Id,
      'product_id': ready2Id,
      'lens_product_id': null,
      'selected_color': 'Be',
      'quantity': 2,
      'price': 700000,
    });

    final date4 = now.subtract(const Duration(days: 3));
    int order4Id = await db.insert('orders', {
      'user_id': guestUserId,
      'order_date': date4.toIso8601String(),
      'total_amount': 1400000,
      'status': 'COMPLETED',
      'payment_method': 'COD',
      'created_at': date4.toIso8601String(),
    });

    await db.insert('order_items', {
      'order_id': order4Id,
      'product_id': frame3Id,
      'lens_product_id': lens3Id,
      'selected_color': 'Đỏ Rượu',
      'quantity': 1,
      'price': 1400000,
    });

    final date5 = now.subtract(const Duration(days: 4));
    int order5Id = await db.insert('orders', {
      'user_id': guestUserId,
      'order_date': date5.toIso8601String(),
      'total_amount': 1000000,
      'status': 'PENDING',
      'payment_method': 'COD',
      'created_at': date5.toIso8601String(),
    });

    await db.insert('order_items', {
      'order_id': order5Id,
      'product_id': ready1Id,
      'lens_product_id': null,
      'selected_color': 'Xanh Rêu',
      'quantity': 1,
      'price': 750000,
    });

    await db.insert('order_items', {
      'order_id': order5Id,
      'product_id': frame2Id,
      'lens_product_id': null,
      'selected_color': 'Trong Suốt',
      'quantity': 1,
      'price': 250000,
    });
  }

  Future<List<Category>> getAllCategories() async {
    final db = await instance.database;
    final result = await db.query('categories');
    return result.map((json) => Category.fromMap(json)).toList();
  }

  Future<List<Product>> getProductsByType(String type) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT p.* FROM products p
      INNER JOIN categories c ON p.category_id = c.category_id
      WHERE c.type = ?
    ''', [type]);

    return result.map((json) => Product.fromMap(json)).toList();
  }

  Future<void> addToCart(
      int userId,
      int productId,
      int? lensId,
      double price, {
        String? color,
        int quantity = 1,
      }) async {
    final db = await instance.database;

    List<Map> pendingOrders = await db.query(
      'orders',
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, 'CART'],
    );

    int orderId;
    if (pendingOrders.isEmpty) {
      orderId = await db.insert('orders', {
        'user_id': userId,
        'order_date': DateTime.now().toIso8601String(),
        'total_amount': 0,
        'status': 'CART',
        'payment_method': 'COD',
        'created_at': DateTime.now().toIso8601String(),
      });
    } else {
      orderId = pendingOrders.first['order_id'] as int;
    }

    await db.insert('order_items', {
      'order_id': orderId,
      'product_id': productId,
      'lens_product_id': lensId,
      'selected_color': color,
      'quantity': quantity,
      'price': price * quantity,
    });

    print("Đã thêm sản phẩm $productId (Kèm lens: $lensId) vào giỏ hàng $orderId");
  }

  Future<int> registerUser(User user) async {
    final db = await instance.database;
    try {
      User hashedUser = User(
        id: user.id,
        username: user.username,
        password: _hashPassword(user.password),
        fullName: user.fullName,
        email: user.email,
        phone: user.phone,
        address: user.address,
        role: user.role,
      );

      return await db.insert('users', hashedUser.toMap());
    } catch (e) {
      print("Lỗi đăng ký: $e");
      return -1;
    }
  }

  Future<User?> login(String username, String password) async {
    final db = await instance.database;

    String hashedPassword = _hashPassword(password);

    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, hashedPassword],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null;
  }

  Future<User> handleGoogleLogin(String email, String fullName) async {
    final db = await instance.database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    } else {
      String generatedUsername = email.split('@')[0];

      User newGoogleUser = User(
        username: generatedUsername,
        password: 'GOOGLE_AUTH_NO_PASSWORD',
        fullName: fullName,
        email: email,
        phone: '',
        address: '',
        role: 'CUSTOMER',
      );

      int id = await db.insert('users', {
        ...newGoogleUser.toMap(),
        'created_at': DateTime.now().toIso8601String()
      });

      return User(
        id: id,
        username: newGoogleUser.username,
        password: newGoogleUser.password,
        fullName: newGoogleUser.fullName,
        email: newGoogleUser.email,
        phone: newGoogleUser.phone,
        address: newGoogleUser.address,
        role: newGoogleUser.role,
      );
    }
  }

  Future<int> updateUser(User user) async {
    final db = await instance.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'user_id = ?',
      whereArgs: [user.id],
    );
  }

  Future<List<Map<String, dynamic>>> getOrderHistory(int userId) async {
    final db = await instance.database;
    return await db.query(
      'orders',
      where: 'user_id = ? AND status != ?',
      whereArgs: [userId, 'CART'],
      orderBy: 'order_id DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getCartItems(int userId) async {
    final db = await instance.database;
    final orders = await db.query(
      'orders',
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, 'CART'],
    );

    if (orders.isEmpty) return [];

    int orderId = orders.first['order_id'] as int;

    return await db.rawQuery('''
      SELECT 
        oi.order_item_id, oi.quantity, oi.price as item_total_price, oi.selected_color,
        p.name as product_name, p.image_url as product_image, p.stock as product_stock,
        l.name as lens_name
      FROM order_items oi
      JOIN products p ON oi.product_id = p.product_id
      LEFT JOIN products l ON oi.lens_product_id = l.product_id
      WHERE oi.order_id = ?
    ''', [orderId]);
  }

  Future<void> updateCartItemQuantity(
      int orderItemId,
      int newQuantity,
      double unitPrice,
      ) async {
    final db = await instance.database;
    await db.update(
      'order_items',
      {
        'quantity': newQuantity,
        'price': unitPrice * newQuantity,
      },
      where: 'order_item_id = ?',
      whereArgs: [orderItemId],
    );
  }

  Future<void> removeFromCart(int orderItemId) async {
    final db = await instance.database;
    await db.delete(
      'order_items',
      where: 'order_item_id = ?',
      whereArgs: [orderItemId],
    );
  }

  Future<void> checkoutCart(int userId) async {
    final db = await instance.database;
    final orders = await db.query(
      'orders',
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, 'CART'],
    );

    if (orders.isNotEmpty) {
      int orderId = orders.first['order_id'] as int;
      await db.update(
        'orders',
        {
          'status': 'PENDING',
          'order_date': DateTime.now().toIso8601String(),
        },
        where: 'order_id = ?',
        whereArgs: [orderId],
      );
    }
  }

  Future<int> getCartItemCount(int userId) async {
    final db = await instance.database;
    final orders = await db.query(
      'orders',
      where: 'user_id = ? AND status = ?',
      whereArgs: [userId, 'CART'],
    );

    if (orders.isEmpty) return 0;

    int orderId = orders.first['order_id'] as int;
    final items = await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );

    return items.length;
  }

  Future<List<Map<String, dynamic>>> getAllUsersForAdmin() async {
    final db = await instance.database;
    return await db.query(
      'users',
      orderBy: 'user_id DESC',
    );
  }

  Future<int> addUserByAdmin({
    required String username,
    required String password,
    required String fullName,
    required String email,
    required String role,
    String phone = '',
    String address = '',
    String status = 'ACTIVE',
  }) async {
    final db = await instance.database;

    return await db.insert('users', {
      'username': username,
      'password': _hashPassword(password),
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role,
      'status': status,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<int> updateUserByAdmin({
    required int userId,
    required String username,
    required String fullName,
    required String email,
    required String role,
    required String status,
    String phone = '',
    String address = '',
    String? newPassword,
  }) async {
    final db = await instance.database;

    final data = <String, dynamic>{
      'username': username,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role,
      'status': status,
    };

    if (newPassword != null && newPassword.trim().isNotEmpty) {
      data['password'] = _hashPassword(newPassword.trim());
    }

    return await db.update(
      'users',
      data,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> deleteUserByAdmin(int userId) async {
    final db = await instance.database;
    return await db.delete(
      'users',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<Map<String, dynamic>> getRevenueSummary() async {
    final db = await instance.database;

    final totalRevenueResult = await db.rawQuery('''
      SELECT COALESCE(SUM(oi.price), 0) AS total_revenue
      FROM orders o
      JOIN order_items oi ON o.order_id = oi.order_id
      WHERE o.status != 'CART'
    ''');

    final totalOrdersResult = await db.rawQuery('''
      SELECT COUNT(*) AS total_orders
      FROM orders
      WHERE status != 'CART'
    ''');

    final totalCustomersResult = await db.rawQuery('''
      SELECT COUNT(DISTINCT user_id) AS total_customers
      FROM orders
      WHERE status != 'CART'
    ''');

    return {
      'totalRevenue':
      (totalRevenueResult.first['total_revenue'] as num?)?.toDouble() ?? 0,
      'totalOrders':
      (totalOrdersResult.first['total_orders'] as num?)?.toInt() ?? 0,
      'totalCustomers':
      (totalCustomersResult.first['total_customers'] as num?)?.toInt() ?? 0,
    };
  }

  Future<List<Map<String, dynamic>>> getRevenueByCategory() async {
    final db = await instance.database;

    return await db.rawQuery('''
      SELECT c.type AS category_type, COALESCE(SUM(oi.price), 0) AS revenue
      FROM orders o
      JOIN order_items oi ON o.order_id = oi.order_id
      JOIN products p ON oi.product_id = p.product_id
      JOIN categories c ON p.category_id = c.category_id
      WHERE o.status != 'CART'
      GROUP BY c.type
      ORDER BY revenue DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getRevenueLast7Days() async {
    final db = await instance.database;

    return await db.rawQuery('''
      SELECT substr(o.order_date, 1, 10) AS day, COALESCE(SUM(oi.price), 0) AS revenue
      FROM orders o
      JOIN order_items oi ON o.order_id = oi.order_id
      WHERE o.status != 'CART'
      GROUP BY substr(o.order_date, 1, 10)
      ORDER BY day DESC
      LIMIT 7
    ''');
  }
  Future<List<Map<String, dynamic>>> getCustomerUsersForAdmin() async {
    final db = await instance.database;
    return await db.query(
      'users',
      where: 'role = ?',
      whereArgs: ['CUSTOMER'],
      orderBy: 'user_id DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getStaffUsersForAdmin() async {
    final db = await instance.database;
    return await db.query(
      'users',
      where: 'role = ? OR role = ?',
      whereArgs: ['ADMIN', 'STAFF'],
      orderBy: 'user_id DESC',
    );
  }
  // ==========================================================
  // --- ADMIN: ORDER CRUD ---
  // ==========================================================

  Future<List<Map<String, dynamic>>> getAllOrdersForAdmin() async {
    final db = await instance.database;

    return await db.rawQuery('''
      SELECT 
        o.order_id,
        o.user_id,
        o.order_date,
        o.total_amount,
        o.status,
        o.payment_method,
        u.full_name,
        u.username
      FROM orders o
      LEFT JOIN users u ON o.user_id = u.user_id
      ORDER BY o.order_id DESC
    ''');
  }

  Future<int> updateOrderStatusByAdmin({
    required int orderId,
    required String status,
  }) async {
    final db = await instance.database;

    double totalAmount = 0;
    final totalResult = await db.rawQuery('''
      SELECT COALESCE(SUM(price), 0) as total
      FROM order_items
      WHERE order_id = ?
    ''', [orderId]);

    if (totalResult.isNotEmpty) {
      totalAmount = (totalResult.first['total'] as num?)?.toDouble() ?? 0;
    }

    return await db.update(
      'orders',
      {
        'status': status,
        'total_amount': totalAmount,
        'order_date': DateTime.now().toIso8601String(),
      },
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }

  Future<int> deleteOrderByAdmin(int orderId) async {
    final db = await instance.database;

    await db.delete(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );

    return await db.delete(
      'orders',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
  }
  // ==========================================================
  // --- ADMIN: PRODUCT CRUD ---
  // ==========================================================

  Future<List<Map<String, dynamic>>> getAllProductsForAdmin() async {
    final db = await instance.database;

    return await db.rawQuery('''
      SELECT 
        p.product_id,
        p.category_id,
        p.name,
        p.description,
        p.price,
        p.image_url,
        p.stock,
        p.status,
        p.specs,
        c.type AS category_type
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.category_id
      ORDER BY p.product_id DESC
    ''');
  }

  Future<int?> getCategoryIdByType(String type) async {
    final db = await instance.database;

    final result = await db.query(
      'categories',
      where: 'type = ?',
      whereArgs: [type],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['category_id'] as int;
    }
    return null;
  }

  Future<int> addProductByAdmin({
    required String categoryType,
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required int stock,
    required String status,
    required String specs,
  }) async {
    final db = await instance.database;
    final categoryId = await getCategoryIdByType(categoryType);

    if (categoryId == null) {
      throw Exception('Không tìm thấy category type: $categoryType');
    }

    return await db.insert('products', {
      'category_id': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'stock': stock,
      'status': status,
      'specs': specs,
    });
  }

  Future<int> updateProductByAdmin({
    required int productId,
    required String categoryType,
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required int stock,
    required String status,
    required String specs,
  }) async {
    final db = await instance.database;
    final categoryId = await getCategoryIdByType(categoryType);

    if (categoryId == null) {
      throw Exception('Không tìm thấy category type: $categoryType');
    }

    return await db.update(
      'products',
      {
        'category_id': categoryId,
        'name': name,
        'description': description,
        'price': price,
        'image_url': imageUrl,
        'stock': stock,
        'status': status,
        'specs': specs,
      },
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  Future<int> deleteProductByAdmin(int productId) async {
    final db = await instance.database;

    await db.delete(
      'order_items',
      where: 'product_id = ? OR lens_product_id = ?',
      whereArgs: [productId, productId],
    );

    return await db.delete(
      'products',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }
  // ==========================================================
  // --- ADMIN: ORDER DETAIL ---
  // ==========================================================

  Future<Map<String, dynamic>?> getOrderHeaderById(int orderId) async {
    final db = await instance.database;

    final result = await db.rawQuery('''
      SELECT 
        o.order_id,
        o.user_id,
        o.order_date,
        o.total_amount,
        o.status,
        o.payment_method,
        u.full_name,
        u.username,
        u.email
      FROM orders o
      LEFT JOIN users u ON o.user_id = u.user_id
      WHERE o.order_id = ?
      LIMIT 1
    ''', [orderId]);

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getOrderItemsByOrderIdForAdmin(int orderId) async {
    final db = await instance.database;

    return await db.rawQuery('''
      SELECT 
        oi.order_item_id,
        oi.quantity,
        oi.price AS item_total_price,
        oi.selected_color,
        p.name AS product_name,
        p.image_url AS product_image,
        l.name AS lens_name
      FROM order_items oi
      JOIN products p ON oi.product_id = p.product_id
      LEFT JOIN products l ON oi.lens_product_id = l.product_id
      WHERE oi.order_id = ?
      ORDER BY oi.order_item_id DESC
    ''', [orderId]);
  }
  Future<Map<String, dynamic>> getAdminDashboardStats() async {
    final db = await instance.database;

    final customerResult = await db.rawQuery('''
    SELECT COUNT(*) AS total
    FROM users
    WHERE role = 'CUSTOMER'
  ''');

    final staffResult = await db.rawQuery('''
    SELECT COUNT(*) AS total
    FROM users
    WHERE role = 'ADMIN' OR role = 'STAFF'
  ''');

    final productResult = await db.rawQuery('''
    SELECT COUNT(*) AS total
    FROM products
  ''');

    final orderResult = await db.rawQuery('''
    SELECT COUNT(*) AS total
    FROM orders
    WHERE status != 'CART'
  ''');

    final revenueResult = await db.rawQuery('''
    SELECT COALESCE(SUM(oi.price), 0) AS total
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status != 'CART'
  ''');

    return {
      'totalCustomers': (customerResult.first['total'] as num?)?.toInt() ?? 0,
      'totalStaff': (staffResult.first['total'] as num?)?.toInt() ?? 0,
      'totalProducts': (productResult.first['total'] as num?)?.toInt() ?? 0,
      'totalOrders': (orderResult.first['total'] as num?)?.toInt() ?? 0,
      'totalRevenue': (revenueResult.first['total'] as num?)?.toDouble() ?? 0,
    };
  }
}