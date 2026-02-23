import 'dart:convert';

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

  Map<String, dynamic> get specsMap {
    if (specs == null || specs!.isEmpty) return {};
    try {
      return jsonDecode(specs!);
    } catch (e) {
      return {};
    }
  }

  factory Product.fromMap(Map<String, dynamic> json) => Product(
    id: json['product_id'],
    categoryId: json['category_id'],
    name: (json['name'] ?? '') as String,
    description: (json['description'] ?? '') as String,
    price: (json['price'] is int)
        ? (json['price'] as int).toDouble()
        : (json['price'] ?? 0.0) as double,
    imageUrl: (json['image_url'] ?? '') as String,
    stock: (json['stock'] ?? 0) as int,
    status: (json['status'] ?? '') as String,
    specs: json['specs'] as String?,
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

  Product copyWith({
    int? id,
    int? categoryId,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    int? stock,
    String? status,
    String? specs,
  }) {
    return Product(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock,
      status: status ?? this.status,
      specs: specs ?? this.specs,
    );
  }
}
