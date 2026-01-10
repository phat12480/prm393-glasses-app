class CartItem {
  final String itemType; // 'ready' | 'build'
  final int? productId;
  final int? frameId;
  final int? lensId;

  final String title;
  final String description; // build config text
  final int unitPrice; // VND
  final int quantity;

  const CartItem({
    required this.itemType,
    required this.title,
    required this.description,
    required this.unitPrice,
    required this.quantity,
    this.productId,
    this.frameId,
    this.lensId,
  });

  int get subtotal => unitPrice * quantity;

  CartItem copyWith({
    int? quantity,
    String? title,
    String? description,
    int? unitPrice,
    String? itemType,
    int? productId,
    int? frameId,
    int? lensId,
  }) {
    return CartItem(
      itemType: itemType ?? this.itemType,
      productId: productId ?? this.productId,
      frameId: frameId ?? this.frameId,
      lensId: lensId ?? this.lensId,
      title: title ?? this.title,
      description: description ?? this.description,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }
}
