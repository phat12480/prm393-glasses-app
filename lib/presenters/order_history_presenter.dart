import '../db/database_helper.dart';

abstract class OrderHistoryView {
  void showLoading();
  void hideLoading();
  void onLoadSuccess(List<Map<String, dynamic>> orders);
  void onError(String message);
}

class OrderHistoryPresenter {
  final OrderHistoryView _view;
  OrderHistoryPresenter(this._view);

  void loadOrderHistory(int userId) async {
    _view.showLoading();
    try {
      final orders = await DatabaseHelper.instance.getOrderHistory(userId);
      _view.hideLoading();
      _view.onLoadSuccess(orders);
    } catch (e) {
      _view.hideLoading();
      _view.onError("Lỗi tải lịch sử: $e");
    }
  }
}