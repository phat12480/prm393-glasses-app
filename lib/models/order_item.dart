class OrderItem {
  final int? id;
  final int orderId;
  final int productId;
  final int? lensProductId;
  final int quantity;
  final double price;

  // field thêm cho admin/detail UI
  final String productName;
  final String lensName;
  final String selectedColor;
  final String productImage;

  OrderItem({
    this.id,
    required this.orderId,
    required this.productId,
    this.lensProductId,
    required this.quantity,
    required this.price,
    this.productName = '',
    this.lensName = '',
    this.selectedColor = '',
    this.productImage = '',
  });

  factory OrderItem.fromMap(Map<String, dynamic> json) => OrderItem(
    id: json['order_item_id'],
    orderId: json['order_id'] ?? 0,
    productId: json['product_id'] ?? 0,
    lensProductId: json['lens_product_id'],
    quantity: json['quantity'] ?? 0,
    price: (json['price'] as num?)?.toDouble() ?? 0,
    productName: json['product_name'] ?? '',
    lensName: json['lens_name'] ?? '',
    selectedColor: json['selected_color'] ?? '',
    productImage: json['product_image'] ?? '',
  );

  Map<String, dynamic> toMap() {
    return {
      'order_item_id': id,
      'order_id': orderId,
      'product_id': productId,
      'lens_product_id': lensProductId,
      'quantity': quantity,
      'price': price,
      'selected_color': selectedColor,
    };
  }
}