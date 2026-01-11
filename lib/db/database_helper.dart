import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

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
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure, // Quan trọng: Bật tính năng khóa ngoại
    );
  }

  Future _onConfigure(Database db) async {
    // Bật ràng buộc khóa ngoại (Foreign Key Constraints)
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    // 1. Bảng Users
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

    // 2. Bảng Categories
    await db.execute('''
    CREATE TABLE categories (
      category_id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      type TEXT NOT NULL
    )
    ''');

    // 3. Bảng Products (Có stock là INT, thêm specs)
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

    // 4. Bảng Orders
    await db.execute('''
    CREATE TABLE orders (
      order_id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      order_date TEXT,
      total_amount REAL,
      status TEXT, -- 'CART', 'PENDING', 'COMPLETED'
      payment_method TEXT,
      created_at TEXT,
      FOREIGN KEY (user_id) REFERENCES users (user_id)
    )
    ''');

    // 5. Bảng Order Items (Quan trọng: Có lens_product_id)
    await db.execute('''
    CREATE TABLE order_items (
      order_item_id INTEGER PRIMARY KEY AUTOINCREMENT,
      order_id INTEGER,
      product_id INTEGER,
      lens_product_id INTEGER,
      quantity INTEGER,
      price REAL,
      FOREIGN KEY (order_id) REFERENCES orders (order_id),
      FOREIGN KEY (product_id) REFERENCES products (product_id),
      FOREIGN KEY (lens_product_id) REFERENCES products (product_id)
    )
    ''');

    // Gọi hàm tạo dữ liệu mẫu
    await _seedData(db);
  }

  // --- HÀM SEED DATA (Dữ liệu mẫu để test) ---
  Future _seedData(Database db) async {
    // Tạo User mẫu
    await db.insert('users', {
      'username': 'guest',
      'password': '123',
      'full_name': 'Khách Trải Nghiệm',
      'role': 'CUSTOMER',
      'created_at': DateTime.now().toIso8601String()
    });

    // Tạo Category
    int catFrame = await db.insert('categories', {'name': 'Gọng Thời Trang', 'type': 'FRAME'});
    int catLens = await db.insert('categories', {'name': 'Tròng Thuốc', 'type': 'LENS'});
    int catReady = await db.insert('categories', {'name': 'Kính Râm', 'type': 'READY'});

    // Tạo Product - Gọng
    await db.insert('products', {
      'category_id': catFrame,
      'name': 'Gọng Titan Tròn',
      'description': 'Siêu nhẹ, bền',
      'price': 500000,
      'stock': 100,
      'status': 'ACTIVE',
      'specs': '{"material": "Titanium", "shape": "Round"}'
    });

    // Tạo Product - Tròng
    await db.insert('products', {
      'category_id': catLens,
      'name': 'Tròng Chống Ánh Sáng Xanh',
      'description': 'Bảo vệ mắt khỏi màn hình',
      'price': 250000,
      'stock': 100,
      'status': 'ACTIVE',
      'specs': '{"feature": "BlueCut", "index": "1.56"}'
    });

    // Tạo Product - Kính sẵn
    await db.insert('products', {
      'category_id': catReady,
      'name': 'Kính Mát CoolNgau',
      'description': 'Phong cách mùa hè',
      'price': 150000,
      'stock': 50,
      'status': 'ACTIVE',
      'specs': '{"uv": "UV400"}'
    });
  }

  // --- CÁC HÀM TRUY VẤN CƠ BẢN (Helper Methods) ---

  // Lấy tất cả danh mục
  Future<List<Category>> getAllCategories() async {
    final db = await instance.database;
    final result = await db.query('categories');
    return result.map((json) => Category.fromMap(json)).toList();
  }

  // Lấy sản phẩm theo loại (FRAME, LENS, READY)
  // Ta phải join bảng Categories để lọc theo type
  Future<List<Product>> getProductsByType(String type) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT p.* FROM products p
      INNER JOIN categories c ON p.category_id = c.category_id
      WHERE c.type = ?
    ''', [type]);

    return result.map((json) => Product.fromMap(json)).toList();
  }

  // Thêm vào giỏ hàng (Logic đơn giản hóa)
  Future<void> addToCart(int userId, int productId, int? lensId, double price) async {
    final db = await instance.database;

    // 1. Tìm xem user có đơn hàng nào đang là CART không
    List<Map> pendingOrders = await db.query('orders',
        where: 'user_id = ? AND status = ?',
        whereArgs: [userId, 'CART']
    );

    int orderId;
    if (pendingOrders.isEmpty) {
      // Nếu chưa có giỏ hàng, tạo mới
      orderId = await db.insert('orders', {
        'user_id': userId,
        'order_date': DateTime.now().toIso8601String(),
        'total_amount': 0,
        'status': 'CART',
        'payment_method': 'COD'
      });
    } else {
      orderId = pendingOrders.first['order_id'];
    }

    // 2. Thêm item vào bảng order_items
    await db.insert('order_items', {
      'order_id': orderId,
      'product_id': productId,
      'lens_product_id': lensId, // Có thể null
      'quantity': 1,
      'price': price
    });

    print("Đã thêm sản phẩm $productId (Kèm lens: $lensId) vào giỏ hàng $orderId");
  }
}
