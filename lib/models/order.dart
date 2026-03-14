class Order {
  final int? id;
  final int userId;
  final String orderDate;
  final double totalAmount;
  final String status;
  final String paymentMethod;

  // field thêm cho admin UI
  final String customerName;

  Order({
    this.id,
    required this.userId,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    this.customerName = '',
  });

  factory Order.fromMap(Map<String, dynamic> json) => Order(
    id: json['order_id'],
    userId: json['user_id'] ?? 0,
    orderDate: json['order_date'] ?? '',
    totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
    status: json['status'] ?? '',
    paymentMethod: json['payment_method'] ?? '',
    customerName: json['customer_name'] ??
        json['full_name'] ??
        json['username'] ??
        '',
  );

  Map<String, dynamic> toMap() {
    return {
      'order_id': id,
      'user_id': userId,
      'order_date': orderDate,
      'total_amount': totalAmount,
      'status': status,
      'payment_method': paymentMethod,
    };
  }
}