import '../models/user.dart';
import '../models/product.dart';
import '../db/database_helper.dart';

// 1. HỢP ĐỒNG CHO VIEW
abstract class ProductDetailView {
  void showLoading();
  void hideLoading();
  void onAddToCartSuccess(); // Thông báo thêm vào giỏ thành công
  void onError(String message); // Thông báo lỗi
  void onUpdateCartCount(int count); // Cập nhật số lượng giỏ hàng
}

// 2. LỚP XỬ LÝ LOGIC (PRESENTER)
class ProductDetailPresenter {
  final ProductDetailView _view;

  ProductDetailPresenter(this._view);

  // Hàm thêm vào giỏ hàng
  void addToCart(User user, Product product, {int? lensId, String? color, int quantity = 1}) async {
    _view.showLoading();

    try {
      await DatabaseHelper.instance.addToCart(
          user.id!,
          product.id!,
          lensId,
          product.price,
          color: color,
          quantity: quantity // Truyền số lượng xuống Database
      );

      _view.hideLoading();
      _view.onAddToCartSuccess();
    } catch (e) {
      _view.hideLoading();
      _view.onError("Lỗi khi thêm vào giỏ hàng: $e");
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