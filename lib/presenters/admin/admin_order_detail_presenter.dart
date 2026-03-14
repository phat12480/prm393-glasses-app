import '../../db/database_helper.dart';
import '../../models/order_item.dart';

abstract class AdminOrderDetailView {
  void showLoading();
  void hideLoading();
  void showOrderHeader(Map<String, dynamic> header);
  void showOrderItems(List<OrderItem> items);
  void showMessage(String message);
}

class AdminOrderDetailPresenter {
  final AdminOrderDetailView view;

  AdminOrderDetailPresenter(this.view);

  Future<void> loadOrderDetail(int orderId) async {
    try {
      view.showLoading();

      final header = await DatabaseHelper.instance.getOrderHeaderById(orderId);
      if (header == null) {
        view.showMessage('Không tìm thấy đơn hàng');
        return;
      }

      final rows =
      await DatabaseHelper.instance.getOrderItemsByOrderIdForAdmin(orderId);

      final items = rows.map((e) {
        return OrderItem(
          id: e['order_item_id'] as int,
          orderId: orderId,
          productId: (e['product_id'] as int?) ?? 0,
          lensProductId: e['lens_product_id'] as int?,
          quantity: (e['quantity'] as num?)?.toInt() ?? 0,
          price: (e['item_total_price'] as num?)?.toDouble() ?? 0,
          productName: (e['product_name'] ?? '').toString(),
          lensName: (e['lens_name'] ?? '').toString(),
          selectedColor: (e['selected_color'] ?? '').toString(),
          productImage: (e['product_image'] ?? '').toString(),
        );
      }).toList();

      view.showOrderHeader(header);
      view.showOrderItems(items);
    } catch (e) {
      view.showMessage('Lỗi tải chi tiết đơn hàng: $e');
    } finally {
      view.hideLoading();
    }
  }
}