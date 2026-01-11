class Category {
  final int? id;
  final String name;
  final String type; // 'FRAME', 'LENS', 'READY'

  Category({this.id, required this.name, required this.type});

  // Chuyển từ Map (SQLite) sang Object
  factory Category.fromMap(Map<String, dynamic> json) => Category(
    id: json['category_id'],
    name: json['name'],
    type: json['type'],
  );

  // Chuyển từ Object sang Map (để lưu vào SQLite)
  Map<String, dynamic> toMap() {
    return {
      'category_id': id,
      'name': name,
      'type': type,
    };
  }
}
