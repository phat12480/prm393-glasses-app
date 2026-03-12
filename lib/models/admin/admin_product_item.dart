class AdminProductItem {
  final int id;
  final int categoryId;
  final String categoryType;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final int stock;
  final String status;
  final String specs;

  AdminProductItem({
    required this.id,
    required this.categoryId,
    required this.categoryType,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.stock,
    required this.status,
    required this.specs,
  });
}