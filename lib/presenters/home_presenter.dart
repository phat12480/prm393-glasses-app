import '../models/product.dart';
import '../db/database_helper.dart';

// 1. HỢP ĐỒNG CHO VIEW
abstract class HomeView {
  void showLoading();
  void hideLoading();
  void onLoadProductsSuccess(Map<String, List<Product>> categorizedProducts);
  void onUpdateCartCount(int count); // Cập nhật số đếm giỏ hàng
  void onLoadError(String message);
}

// 2. LỚP XỬ LÝ LOGIC (PRESENTER)
class HomePresenter {
  final HomeView _view;

  HomePresenter(this._view);

  // Hàm Tải danh sách sản phẩm
  void loadAllProducts() async {
    _view.showLoading();
    try {
      final readyProducts = await DatabaseHelper.instance.getProductsByType('READY');
      final frameProducts = await DatabaseHelper.instance.getProductsByType('FRAME');
      final lensProducts = await DatabaseHelper.instance.getProductsByType('LENS');

      final Map<String, List<Product>> result = {
        'READY': readyProducts,
        'FRAME': frameProducts,
        'LENS': lensProducts,
      };

      _view.hideLoading();
      _view.onLoadProductsSuccess(result);

    } catch (e) {
      _view.hideLoading();
      _view.onLoadError("Lỗi tải dữ liệu: $e");
    }
  }

  // Hàm đếm số lượng giỏ hàng
  void loadCartCount(int userId) async {
    try {
      int count = await DatabaseHelper.instance.getCartItemCount(userId);
      _view.onUpdateCartCount(count);
    } catch (e) {
      print("Lỗi đếm giỏ hàng: $e");
    }
  }
}