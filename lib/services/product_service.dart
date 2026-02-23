import '../db/database_helper.dart';
import '../models/product.dart';

class ProductService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> createProduct(Product product) async {
    if (product.price < 0) {
      throw Exception('Giá sản phẩm không được âm');
    }
    if (product.stock < 0) {
      throw Exception('Số lượng tồn kho không được âm');
    }

    return await _dbHelper.createProduct(product);
  }

  // --- CREATE theo loại ---
  Future<int> createFrameProduct(Product product) async {
    return _createByType(product, 'FRAME');
  }

  Future<int> createLensProduct(Product product) async {
    return _createByType(product, 'LENS');
  }

  Future<int> createReadyProduct(Product product) async {
    return _createByType(product, 'READY');
  }

  Future<List<Product>> getAllProducts() async {
    return await _dbHelper.getAllProducts();
  }

  Future<Product?> getProductById(int id) async {
    return await _dbHelper.getProductById(id);
  }

  Future<int> updateProduct(Product product) async {
    if (product.id == null) {
      throw Exception('ID sản phẩm không được null khi cập nhật');
    }
    if (product.price < 0) {
      throw Exception('Giá sản phẩm không được âm');
    }

    return await _dbHelper.updateProduct(product);
  }

  // --- UPDATE theo loại (ép category về đúng loại) ---
  Future<int> updateFrameProduct(Product product) async {
    return _updateByType(product, 'FRAME');
  }

  Future<int> updateLensProduct(Product product) async {
    return _updateByType(product, 'LENS');
  }

  Future<int> updateReadyProduct(Product product) async {
    return _updateByType(product, 'READY');
  }

  Future<int> deleteProduct(int id) async {
    return await _dbHelper.deleteProduct(id);
  }

  Future<List<Product>> getFrames() async {
    return await _dbHelper.getProductsByType('FRAME');
  }

  Future<List<Product>> getLenses() async {
    return await _dbHelper.getProductsByType('LENS');
  }

  Future<List<Product>> getReadyMadeGlasses() async {
    return await _dbHelper.getProductsByType('READY');
  }

  Future<List<Product>> searchProducts(String keyword) async {
    final all = await getAllProducts();
    return all
        .where((p) => p.name.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
  }

  // --- PRIVATE HELPERS ---
  Future<int> _createByType(Product product, String type) async {
    final categoryId = await _dbHelper.getCategoryIdByType(type);
    if (categoryId == null) {
      throw Exception('Chưa có category cho loại $type');
    }
    return _dbHelper.createProduct(product.copyWith(categoryId: categoryId));
  }

  Future<int> _updateByType(Product product, String type) async {
    if (product.id == null) {
      throw Exception('ID sản phẩm không được null khi cập nhật');
    }
    final categoryId = await _dbHelper.getCategoryIdByType(type);
    if (categoryId == null) {
      throw Exception('Chưa có category cho loại $type');
    }
    return _dbHelper.updateProduct(product.copyWith(categoryId: categoryId));
  }
}
