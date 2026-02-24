import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // Thêm controller mới
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();

  // Thêm 2 biến để quản lý trạng thái ẩn/hiện mật khẩu
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _handleRegister() async {
    // 1. Kiểm tra xem các trường có bị bỏ trống không (Basic validation)
    if (_usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _fullNameController.text.isEmpty ||
        _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin!"))
      );
      return;
    }

    // 2. Kiểm tra mật khẩu và xác nhận mật khẩu có khớp nhau không
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mật khẩu xác nhận không khớp!"))
      );
      return; // Dừng lại, không gọi DB
    }

    // 3. Tiến hành lưu vào Database
    User newUser = User(
      username: _usernameController.text,
      password: _passwordController.text,
      fullName: _fullNameController.text,
      email: _emailController.text,
      phone: '',
      address: '',
      role: 'CUSTOMER',
    );

    int result = await DatabaseHelper.instance.registerUser(newUser);

    if (result != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đăng ký thành công!"))
      );
      Navigator.pop(context); // Quay lại màn hình Login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tên đăng nhập hoặc Email đã tồn tại."))
      );
    }
  }

  // Dọn dẹp bộ nhớ khi tắt màn hình
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  //Giao diện Register
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng ký tài khoản")),
      body: SingleChildScrollView( // Thêm SingleChildScrollView để không bị lỗi UI khi bật bàn phím
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: "Họ và tên")
            ),
            const SizedBox(height: 10),
            TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email")
            ),
            const SizedBox(height: 10),
            TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Tên đăng nhập")
            ),
            const SizedBox(height: 10),

            // Trường Mật khẩu (Có icon ẩn/hiện)
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword, // Sử dụng biến trạng thái
              decoration: InputDecoration(
                labelText: "Mật khẩu",
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword; // Đảo ngược trạng thái
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Trường Xác nhận mật khẩu (Có icon ẩn/hiện)
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword, // Sử dụng biến trạng thái
              decoration: InputDecoration(
                labelText: "Xác nhận mật khẩu",
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword; // Đảo ngược trạng thái
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: _handleRegister,
                child: const Text("Đăng Ký", style: TextStyle(fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}