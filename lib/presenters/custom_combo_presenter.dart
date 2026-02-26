import '../models/user.dart';
import '../models/product.dart';
import '../db/database_helper.dart';

// 1. HỢP ĐỒNG CHO VIEW
abstract class CustomComboView {
  void showLoading();
  void hideLoading();
  void onLoadDataSuccess(List<Product> frames, List<Product> lenses);
  void onAddToCartSuccess();
  void onError(String message);
}

// 2. LỚP XỬ LÝ LOGIC (PRESENTER)
class CustomComboPresenter {
  final CustomComboView _view;

  CustomComboPresenter(this._view);

  // Hàm Tải danh sách Gọng và Tròng cùng lúc
  void loadComboData() async {
    _view.showLoading();
    try {
      final frames = await DatabaseHelper.instance.getProductsByType('FRAME');
      final lenses = await DatabaseHelper.instance.getProductsByType('LENS');

      _view.hideLoading();
      _view.onLoadDataSuccess(frames, lenses);
    } catch (e) {
      _view.hideLoading();
      _view.onError("Lỗi tải dữ liệu: $e");
    }
  }

  // Hàm thêm combo vào giỏ hàng
  void addComboToCart(User user, Product frame, Product lens, String? color) async {
    _view.showLoading();
    try {
      double totalPrice = frame.price + lens.price;

      // Gọi hàm addToCart với tham số color
      await DatabaseHelper.instance.addToCart(
          user.id!,
          frame.id!,
          lens.id,
          totalPrice,
          color: color
      );

      _view.hideLoading();
      _view.onAddToCartSuccess();
    } catch (e) {
      _view.hideLoading();
      _view.onError("Lỗi thêm vào giỏ hàng: $e");
    }
  }
}