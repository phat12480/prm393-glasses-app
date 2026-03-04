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

    // 5. Bảng Order Items
    await db.execute('''
    CREATE TABLE order_items (
      order_item_id INTEGER PRIMARY KEY AUTOINCREMENT,
      order_id INTEGER,
      product_id INTEGER,
      lens_product_id INTEGER,
      selected_color TEXT, -- THÊM DÒNG NÀY ĐỂ LƯU MÀU KÍNH
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

  // --- HÀM SEED DATA (Dữ liệu mẫu phong phú) ---
  Future _seedData(Database db) async {
    // 1. User mẫu
    await db.insert('users', {
      'username': 'guest',
      'password': '123',
      'full_name': 'Khách Trải Nghiệm',
      'role': 'CUSTOMER',
      'created_at': DateTime.now().toIso8601String()
    });

    // 2. Category Mẫu
    int catFrame = await db.insert('categories', {'name': 'Gọng Thời Trang', 'type': 'FRAME'});
    int catLens = await db.insert('categories', {'name': 'Tròng Thuốc', 'type': 'LENS'});
    int catReady = await db.insert('categories', {'name': 'Kính Râm', 'type': 'READY'});

    // ==========================================
    // 3. THÊM CÁC SẢN PHẨM: GỌNG KÍNH (FRAME)
    // ==========================================
    await db.insert('products', {
      'category_id': catFrame,
      'name': 'Gọng Titan Tròn Cổ Điển',
      'description': 'Thiết kế bo tròn thanh lịch, chất liệu Titanium siêu nhẹ không gây vết hằn trên sống mũi.',
      'price': 550000,
      'image_url': 'https://images.unsplash.com/photo-1591076482161-42ce6da69f67?q=80&w=1000&auto=format&fit=crop',
      'stock': 100,
      'status': 'ACTIVE',
      'specs': '{"colors": ["Đen", "Bạc", "Vàng Hồng"], "material": "Titanium", "shape": "Round"}'
    });

    await db.insert('products', {
      'category_id': catFrame,
      'name': 'Gọng Nhựa Dẻo TR90',
      'description': 'Độ đàn hồi cao, bẻ cong không gãy. Phù hợp cho các bạn học sinh, sinh viên năng động.',
      'price': 250000,
      'image_url': 'https://images.unsplash.com/photo-1582142407894-ec85a1260a46?q=80&w=1000&auto=format&fit=crop',
      'stock': 200,
      'status': 'ACTIVE',
      'specs': '{"colors": ["Trong Suốt", "Đen Nhám", "Xanh Navy"], "material": "TR90", "shape": "Square"}'
    });

    await db.insert('products', {
      'category_id': catFrame,
      'name': 'Gọng Mắt Mèo Cá Tính',
      'description': 'Tôn lên đường nét khuôn mặt, giúp gương mặt trở nên sắc sảo và cuốn hút hơn.',
      'price': 450000,
      'image_url': '', // Cố tình để trống để test UI hiển thị icon mặc định
      'stock': 50,
      'status': 'ACTIVE',
      'specs': '{"colors": ["Đồi Mồi", "Đen Bóng", "Đỏ Rượu"], "material": "Acetate", "shape": "Cat-eye"}'
    });

    // ==========================================
    // 4. THÊM CÁC SẢN PHẨM: TRÒNG KÍNH (LENS)
    // ==========================================
    await db.insert('products', {
      'category_id': catLens,
      'name': 'Tròng Chống Ánh Sáng Xanh',
      'description': 'Bảo vệ mắt khỏi tia sáng xanh có hại từ màn hình máy tính, điện thoại. Giảm nhức mỏi mắt.',
      'price': 300000,
      'image_url': 'https://images.unsplash.com/photo-1556306535-0f09a536f0bl?q=80&w=1000&auto=format&fit=crop',
      'stock': 500,
      'status': 'ACTIVE',
      'specs': '{"feature": "BlueCut", "index": "1.56"}'
    });

    await db.insert('products', {
      'category_id': catLens,
      'name': 'Tròng Đổi Màu Đi Nắng',
      'description': 'Tự động chuyển sang màu sậm khi ra ngoài trời nắng và trong suốt trở lại khi vào nhà.',
      'price': 650000,
      'image_url': '',
      'stock': 150,
      'status': 'ACTIVE',
      'specs': '{"feature": "Photochromic", "index": "1.61"}'
    });

    await db.insert('products', {
      'category_id': catLens,
      'name': 'Tròng Siêu Mỏng Chống Xước',
      'description': 'Dành cho người độ cận cao. Tròng mỏng nhẹ hơn 30% so với tròng thường, phủ lớp chống xước cao cấp.',
      'price': 950000,
      'image_url': '',
      'stock': 80,
      'status': 'ACTIVE',
      'specs': '{"feature": "Anti-scratch, Super Thin", "index": "1.67"}'
    });

    // ==========================================
    // 5. THÊM CÁC SẢN PHẨM: KÍNH RÂM (READY)
    // ==========================================
    await db.insert('products', {
      'category_id': catReady,
      'name': 'Kính Râm Phân Cực Polarized',
      'description': 'Chống chói lóa tối đa khi lái xe hoặc đi biển. Bảo vệ mắt tuyệt đối với chuẩn UV400.',
      'price': 750000,
      'image_url': 'https://images.unsplash.com/photo-1511499767150-a48a237f0083?q=80&w=1000&auto=format&fit=crop',
      'stock': 60,
      'status': 'ACTIVE',
      'specs': '{"colors": ["Đen Khói", "Xanh Rêu"], "uv": "UV400 Polarized"}'
    });

    await db.insert('products', {
      'category_id': catReady,
      'name': 'Kính Mát Bản To Thời Trang',
      'description': 'Phụ kiện không thể thiếu cho các tín đồ thời trang. Thiết kế oversize giúp che khuyết điểm hoàn hảo.',
      'price': 350000,
      'image_url': 'https://images.unsplash.com/photo-1574258495973-f010dfbb5371?q=80&w=1000&auto=format&fit=crop',
      'stock': 120,
      'status': 'ACTIVE',
      'specs': '{"colors": ["Trắng Sữa", "Đen", "Be"], "uv": "UV400"}'
    });
  }

  // ==========================================================
  // --- CÁC HÀM TRUY VẤN CƠ BẢN (Helper Methods) ---
  // ==========================================================

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

  // Thêm vào giỏ hàng
  Future<void> addToCart(int userId, int productId, int? lensId, double price, {String? color, int quantity = 1}) async {
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
      'lens_product_id': lensId,
      'selected_color': color,
      'quantity': quantity, // LƯU SỐ LƯỢNG VÀO DB
      'price': price * quantity // NHÂN ĐƠN GIÁ VỚI SỐ LƯỢNG
    });

    print("Đã thêm sản phẩm $productId (Kèm lens: $lensId) vào giỏ hàng $orderId");
  }

  // ==========================================================
  // --- CÁC HÀM XỬ LÝ USER (LOGIN/REGISTER) ---
  // ==========================================================
  // 1. Đăng ký User mới
  Future<int> registerUser(User user) async {
    final db = await instance.database;
    try {
      return await db.insert('users', user.toMap());
    } catch (e) {
      // Bắt lỗi nếu trùng Username hoặc Email (do ta đặt UNIQUE trong DB)
      print("Lỗi đăng ký: $e");
      return -1;
    }
  }

  // 2. Đăng nhập bằng Username & Password
  Future<User?> login(String username, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) {
      return User.fromMap(result.first);
    }
    return null; // Sai tài khoản hoặc mật khẩu
  }

  // 3. Xử lý Google Login (Kiểm tra xem email đã có chưa, chưa thì tự tạo)
  Future<User> handleGoogleLogin(String email, String fullName) async {
    final db = await instance.database;

    // Kiểm tra xem email này đã tồn tại trong SQLite chưa
    final result = await db.query('users', where: 'email = ?', whereArgs: [email]);

    if (result.isNotEmpty) {
      // Đã từng đăng nhập bằng Google, trả về thông tin User
      return User.fromMap(result.first);
    } else {
      // Lần đầu đăng nhập bằng Google -> Tạo User mới trong SQLite
      // Lấy phần đầu của email làm username (VD: abc@gmail.com -> abc)
      String generatedUsername = email.split('@')[0];

      User newGoogleUser = User(
        username: generatedUsername,
        password: 'GOOGLE_AUTH_NO_PASSWORD', // Đánh dấu đây là acc Google
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

  // ==========================================================
  // --- CÁC HÀM XỬ LÝ PROFILE & LỊCH SỬ ĐƠN HÀNG ---
  // ==========================================================

  // 1. Cập nhật thông tin người dùng
  Future<int> updateUser(User user) async {
    final db = await instance.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'user_id = ?',
      whereArgs: [user.id],
    );
  }

  // 2. Lấy danh sách lịch sử đơn hàng (Bỏ qua giỏ hàng 'CART')
  Future<List<Map<String, dynamic>>> getOrderHistory(int userId) async {
    final db = await instance.database;
    return await db.query(
        'orders',
        where: 'user_id = ? AND status != ?',
        whereArgs: [userId, 'CART'],
        orderBy: 'order_id DESC' // Đơn hàng mới nhất xếp trên
    );
  }

  // ==========================================================
  // --- CÁC HÀM XỬ LÝ GIỎ HÀNG VÀ THANH TOÁN ---
  // ==========================================================

  // 1. Lấy danh sách sản phẩm trong giỏ hàng của User
  Future<List<Map<String, dynamic>>> getCartItems(int userId) async {
    final db = await instance.database;
    final orders = await db.query('orders', where: 'user_id = ? AND status = ?', whereArgs: [userId, 'CART']);
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

  // 2. Cập nhật số lượng và tính lại tiền
  Future<void> updateCartItemQuantity(int orderItemId, int newQuantity, double unitPrice) async {
    final db = await instance.database;
    await db.update(
        'order_items',
        {
          'quantity': newQuantity,
          'price': unitPrice * newQuantity // Nhân lại đơn giá với số lượng mới
        },
        where: 'order_item_id = ?',
        whereArgs: [orderItemId]
    );
  }

  // 3. Xóa một sản phẩm khỏi giỏ hàng
  Future<void> removeFromCart(int orderItemId) async {
    final db = await instance.database;
    await db.delete('order_items', where: 'order_item_id = ?', whereArgs: [orderItemId]);
  }

  // 4. Thanh toán (Đổi trạng thái CART -> PENDING)
  Future<void> checkoutCart(int userId) async {
    final db = await instance.database;
    final orders = await db.query('orders', where: 'user_id = ? AND status = ?', whereArgs: [userId, 'CART']);
    if (orders.isNotEmpty) {
      int orderId = orders.first['order_id'] as int;
      await db.update(
          'orders',
          {'status': 'PENDING', 'order_date': DateTime.now().toIso8601String()},
          where: 'order_id = ?',
          whereArgs: [orderId]
      );
    }
  }

  // 5. Đếm số lượng sản phẩm đang có trong giỏ hàng (CART)
  Future<int> getCartItemCount(int userId) async {
    final db = await instance.database;
    final orders = await db.query('orders', where: 'user_id = ? AND status = ?', whereArgs: [userId, 'CART']);

    if (orders.isEmpty) return 0; // Không có giỏ hàng nào đang mở

    int orderId = orders.first['order_id'] as int;
    final items = await db.query('order_items', where: 'order_id = ?', whereArgs: [orderId]);

    return items.length; // Trả về số lượng món hàng
  }

}
