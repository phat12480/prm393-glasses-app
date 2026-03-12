class AdminOrderItem {
  final int id;
  final int userId;
  final String customerName;
  final String orderDate;
  final double totalAmount;
  final String status;
  final String paymentMethod;

  AdminOrderItem({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
  });
}