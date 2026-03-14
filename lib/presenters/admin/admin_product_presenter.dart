import '../../db/database_helper.dart';
import '../../models/product.dart';

abstract class AdminProductView {
  void showProducts(List<Product> products);
  void showMessage(String message);
  void showLoading();
  void hideLoading();
}

class AdminProductPresenter {
  final AdminProductView view;

  AdminProductPresenter(this.view);

  Future<void> loadProducts() async {
    try {
      view.showLoading();

      final result = await DatabaseHelper.instance.getAllProductsForAdmin();

      final products = result.map((e) {
        return Product(
          id: e['product_id'] as int,
          categoryId: (e['category_id'] ?? 0) as int,
          name: (e['name'] ?? '').toString(),
          description: (e['description'] ?? '').toString(),
          price: (e['price'] as num?)?.toDouble() ?? 0,
          imageUrl: (e['image_url'] ?? '').toString(),
          stock: (e['stock'] as num?)?.toInt() ?? 0,
          status: (e['status'] ?? '').toString(),
          specs: (e['specs'] ?? '').toString(),
        );
      }).toList();

      view.showProducts(products);
    } catch (e) {
      view.showMessage('Lỗi tải danh sách sản phẩm: $e');
    } finally {
      view.hideLoading();
    }
  }

  Future<void> addProduct({
    required String categoryType,
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required int stock,
    required String status,
    required String specs,
  }) async {
    try {
      await DatabaseHelper.instance.addProductByAdmin(
        categoryType: categoryType,
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl,
        stock: stock,
        status: status,
        specs: specs,
      );

      view.showMessage('Thêm sản phẩm thành công');
      await loadProducts();
    } catch (e) {
      view.showMessage('Thêm sản phẩm thất bại: $e');
    }
  }

  Future<void> updateProduct({
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
    try {
      await DatabaseHelper.instance.updateProductByAdmin(
        productId: productId,
        categoryType: categoryType,
        name: name,
        description: description,
        price: price,
        imageUrl: imageUrl,
        stock: stock,
        status: status,
        specs: specs,
      );

      view.showMessage('Cập nhật sản phẩm thành công');
      await loadProducts();
    } catch (e) {
      view.showMessage('Cập nhật sản phẩm thất bại: $e');
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      await DatabaseHelper.instance.deleteProductByAdmin(productId);
      view.showMessage('Xóa sản phẩm thành công');
      await loadProducts();
    } catch (e) {
      view.showMessage('Xóa sản phẩm thất bại: $e');
    }
  }
}