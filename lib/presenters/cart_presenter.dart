import '../db/database_helper.dart';

// 1. HỢP ĐỒNG MVP CHO VIEW
abstract class CartView {
  void showLoading();
  void hideLoading();
  void onLoadCartSuccess(List<Map<String, dynamic>> items, double totalPrice);
  void onCartEmpty(); // Khi giỏ hàng trống
  void onCheckoutSuccess();
  void onError(String message);
}

// 2. LỚP XỬ LÝ LOGIC (PRESENTER)
class CartPresenter {
  final CartView _view;

  CartPresenter(this._view);

  // Hàm Tải danh sách giỏ hàng
  void loadCart(int userId) async {
    _view.showLoading();
    try {
      final items = await DatabaseHelper.instance.getCartItems(userId);

      if (items.isEmpty) {
        _view.onCartEmpty();
      } else {
        double total = 0;
        for (var item in items) {
          total += item['item_total_price'];
        }
        _view.onLoadCartSuccess(items, total);
      }
    } catch (e) {
      _view.onError("Lỗi tải giỏ hàng: $e");
    } finally {
      _view.hideLoading();
    }
  }

  // Hàm cập nhật số lượng sản phẩm
  void updateQuantity(int orderItemId, int newQuantity, double unitPrice, int userId) async {
    _view.showLoading();
    try {
      // Cập nhật số lượng vào DB
      await DatabaseHelper.instance.updateCartItemQuantity(orderItemId, newQuantity, unitPrice);
      // Gọi tải lại giỏ hàng để cập nhật Giao diện & Tổng tiền
      loadCart(userId);
    } catch (e) {
      _view.hideLoading();
      _view.onError("Lỗi cập nhật số lượng: $e");
    }
  }

  // Hàm Xóa sản phẩm khỏi giỏ
  void removeItem(int orderItemId, int userId) async {
    _view.showLoading();
    try {
      await DatabaseHelper.instance.removeFromCart(orderItemId);
      loadCart(userId); // Tải lại giỏ hàng sau khi xóa
    } catch (e) {
      _view.hideLoading();
      _view.onError("Lỗi xóa sản phẩm: $e");
    }
  }

  // Hàm thanh toán đơn hàng
  void checkout(int userId) async {
    _view.showLoading();
    try {
      await DatabaseHelper.instance.checkoutCart(userId);
      _view.hideLoading();
      _view.onCheckoutSuccess();
    } catch (e) {
      _view.hideLoading();
      _view.onError("Lỗi thanh toán: $e");
    }
  }
}