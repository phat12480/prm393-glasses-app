class User {
  final int? id;
  final String username;
  final String password;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String role;
  final String status;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.role,
    this.status = 'ACTIVE',
  });

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
      'status': status,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['user_id'],
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      fullName: map['full_name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      role: map['role'] ?? '',
      status: map['status'] ?? 'ACTIVE',
    );
  }
}