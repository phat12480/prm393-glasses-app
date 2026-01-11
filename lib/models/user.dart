class User {
  final int? id;
  final String username;
  final String password;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String role; // 'ADMIN', 'CUSTOMER', 'MANAGER'

  User({
    this.id,
    required this.username,
    required this.password,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
  });

  factory User.fromMap(Map<String, dynamic> json) => User(
    id: json['user_id'],
    username: json['username'],
    password: json['password'],
    fullName: json['full_name'],
    email: json['email'],
    phone: json['phone'],
    address: json['address'],
    role: json['role'],
  );

  Map<String, dynamic> toMap() {
    return {
      'user_id': id,
      'username': username,
      'password': password,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'role': role,
      // created_at sẽ để Database tự sinh hoặc handle riêng
    };
  }
}
