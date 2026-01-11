class Product {
  final int? id;
  final int categoryId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final int stock;
  final String status;
  final String? specs; // JSON String: lưu độ cận, chất liệu, v.v.

  Product({
    this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.stock,
    required this.status,
    this.specs,
  });

  factory Product.fromMap(Map<String, dynamic> json) => Product(
    id: json['product_id'],
    categoryId: json['category_id'],
    name: json['name'],
    description: json['description'],
    price: json['price'],
    imageUrl: json['image_url'],
    stock: json['stock'], // Đã sửa thành int theo diagram mới
    status: json['status'],
    specs: json['specs'],
  );

  Map<String, dynamic> toMap() {
    return {
      'product_id': id,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'stock': stock,
      'status': status,
      'specs': specs,
    };
  }
}
