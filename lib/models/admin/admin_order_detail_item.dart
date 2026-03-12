class AdminOrderDetailItem {
  final int orderItemId;
  final String productName;
  final String lensName;
  final String selectedColor;
  final int quantity;
  final double itemTotalPrice;
  final String productImage;

  AdminOrderDetailItem({
    required this.orderItemId,
    required this.productName,
    required this.lensName,
    required this.selectedColor,
    required this.quantity,
    required this.itemTotalPrice,
    required this.productImage,
  });
}