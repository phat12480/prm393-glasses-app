import 'package:flutter/material.dart';
import '../models/user.dart';
import '../presenters/register_presenter.dart'; // Import Presenter vào

// CHÚ Ý: Class State bây giờ "implements RegisterView" (Ký hợp đồng với Presenter)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> implements RegisterView {
  // Khai báo Presenter
  late RegisterPresenter _presenter;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false; // Biến trạng thái loading

  @override
  void initState() {
    super.initState();
    // Khởi tạo Presenter và truyền chính màn hình này (this) vào làm View
    _presenter = RegisterPresenter(this);
  }

  // ==========================================================
  // THỰC THI CÁC HÀM CỦA HỢP ĐỒNG MVP (CONTRACT IMPLEMENTATION)
  // ==========================================================
  @override
  void showLoading() {
    setState(() => _isLoading = true);
  }

  @override
  void hideLoading() {
    setState(() => _isLoading = false);
  }

  @override
  void onRegisterSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đăng ký thành công!"))
    );
    Navigator.pop(context); // Quay lại màn hình Login
  }

  @override
  void onRegisterError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message))
    );
  }
  // ==========================================================

  // Hàm khi người dùng bấm nút Đăng ký
  void _onRegisterBtnClicked() {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty ||
        _fullNameController.text.isEmpty || _emailController.text.isEmpty) {
      onRegisterError("Vui lòng điền đầy đủ thông tin!");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      onRegisterError("Mật khẩu xác nhận không khớp!");
      return;
    }

    User newUser = User(
      username: _usernameController.text,
      password: _passwordController.text,
      fullName: _fullNameController.text,
      email: _emailController.text,
      phone: '',
      address: '',
      role: 'CUSTOMER',
    );

    // Bàn giao toàn bộ việc đăng ký cho Presenter xử lý!
    _presenter.handleRegister(newUser);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng ký tài khoản")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _fullNameController, decoration: const InputDecoration(labelText: "Họ và tên")),
            const SizedBox(height: 10),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
            const SizedBox(height: 10),
            TextField(controller: _usernameController, decoration: const InputDecoration(labelText: "Tên đăng nhập")),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: "Mật khẩu",
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: "Xác nhận mật khẩu",
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Xử lý nút bấm: Nếu đang loading thì hiện vòng xoay, ngược lại hiện nút
            SizedBox(
              width: double.infinity,
              height: 45,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _onRegisterBtnClicked, // Gọi hàm mới
                child: const Text("Đăng Ký", style: TextStyle(fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}