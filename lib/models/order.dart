class Order {
  final int? id;
  final int userId;
  final String orderDate;
  final double totalAmount;
  final String status; // 'CART', 'PENDING', 'COMPLETED'
  final String paymentMethod;

  Order({
    this.id,
    required this.userId,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
  });

  factory Order.fromMap(Map<String, dynamic> json) => Order(
    id: json['order_id'],
    userId: json['user_id'],
    orderDate: json['order_date'],
    totalAmount: json['total_amount'] is String
        ? double.parse(json['total_amount'])
        : json['total_amount'], // SQLite đôi khi trả về int nếu số chẵn
    status: json['status'],
    paymentMethod: json['payment_method'],
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
