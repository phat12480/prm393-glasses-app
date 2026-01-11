class OrderItem {
  final int? id;
  final int orderId;
  final int productId;      // ID Gọng hoặc Kính có sẵn
  final int? lensProductId; // ID Tròng kính (Có thể null)
  final int quantity;
  final double price;       // Giá tại thời điểm mua (đã cộng gộp)

  OrderItem({
    this.id,
    required this.orderId,
    required this.productId,
    this.lensProductId,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromMap(Map<String, dynamic> json) => OrderItem(
    id: json['order_item_id'],
    orderId: json['order_id'],
    productId: json['product_id'],
    lensProductId: json['lens_product_id'], // SQLite trả về null thì Dart nhận null
    quantity: json['quantity'],
    price: json['price'],
  );

  Map<String, dynamic> toMap() {
    return {
      'order_item_id': id,
      'order_id': orderId,
      'product_id': productId,
      'lens_product_id': lensProductId,
      'quantity': quantity,
      'price': price,
    };
  }
}
