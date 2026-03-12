import '../../db/database_helper.dart';
import '../../models/admin/admin_order_item.dart';

abstract class AdminOrderView {
  void showOrders(List<AdminOrderItem> orders);
  void showMessage(String message);
  void showLoading();
  void hideLoading();
}

class AdminOrderPresenter {
  final AdminOrderView view;

  AdminOrderPresenter(this.view);

  Future<void> loadOrders() async {
    try {
      view.showLoading();

      final result = await DatabaseHelper.instance.getAllOrdersForAdmin();

      final orders = result.map((e) {
        final fullName = (e['full_name'] ?? '').toString();
        final username = (e['username'] ?? '').toString();

        return AdminOrderItem(
          id: e['order_id'] as int,
          userId: (e['user_id'] as int?) ?? 0,
          customerName: fullName.isNotEmpty ? fullName : username,
          orderDate: (e['order_date'] ?? '').toString(),
          totalAmount: (e['total_amount'] as num?)?.toDouble() ?? 0,
          status: (e['status'] ?? '').toString(),
          paymentMethod: (e['payment_method'] ?? '').toString(),
        );
      }).toList();

      view.showOrders(orders);
    } catch (e) {
      view.showMessage('Lỗi tải danh sách order: $e');
    } finally {
      view.hideLoading();
    }
  }

  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    try {
      await DatabaseHelper.instance.updateOrderStatusByAdmin(
        orderId: orderId,
        status: status,
      );

      view.showMessage('Cập nhật trạng thái đơn hàng thành công');
      await loadOrders();
    } catch (e) {
      view.showMessage('Cập nhật trạng thái thất bại: $e');
    }
  }

  Future<void> deleteOrder(int orderId) async {
    try {
      await DatabaseHelper.instance.deleteOrderByAdmin(orderId);
      view.showMessage('Xóa đơn hàng thành công');
      await loadOrders();
    } catch (e) {
      view.showMessage('Xóa đơn hàng thất bại: $e');
    }
  }
}