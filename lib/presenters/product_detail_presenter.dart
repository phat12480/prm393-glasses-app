import '../models/user.dart';
import '../models/product.dart';
import '../db/database_helper.dart';

// 1. HỢP ĐỒNG CHO VIEW
abstract class ProductDetailView {
  void showLoading();
  void hideLoading();
  void onAddToCartSuccess();
  void onError(String message);
}

// 2. LỚP XỬ LÝ LOGIC (PRESENTER)
class ProductDetailPresenter {
  final ProductDetailView _view;

  ProductDetailPresenter(this._view);

  // Hàm xử lý Thêm vào giỏ hàng
  void addToCart(User user, Product product, {int? lensId}) async {
    _view.showLoading();

    try {
      // Gọi hàm addToCart trong SQLite (Truyền ID user, ID sản phẩm, ID tròng kính (nếu có), và Giá)
      await DatabaseHelper.instance.addToCart(
          user.id!,
          product.id!,
          lensId,
          product.price
      );

      _view.hideLoading();
      _view.onAddToCartSuccess();
    } catch (e) {
      _view.hideLoading();
      _view.onError("Lỗi khi thêm vào giỏ hàng: $e");
    }
  }
}