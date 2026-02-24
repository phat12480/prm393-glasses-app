import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';
import '../presenters/login_presenter.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

// Chú ý: Ký hợp đồng implements LoginView
class _LoginScreenState extends State<LoginScreen> implements LoginView {
  late LoginPresenter _presenter;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo Presenter
    _presenter = LoginPresenter(this);
  }

  // ==========================================================
  // THỰC THI CÁC HÀM CỦA HỢP ĐỒNG MVP
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
  void onLoginSuccess(User user) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Xin chào, ${user.fullName}!"))
    );
    // Đăng nhập thành công -> Chuyển sang Home
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(user: user))
    );
  }

  @override
  void onLoginError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message))
    );
  }
  // ==========================================================

  // Hàm khi bấm nút "Đăng nhập"
  void _onLoginNormalClicked() {
    // Giao việc cho Presenter
    _presenter.handleNormalLogin(
        _usernameController.text.trim(),
        _passwordController.text.trim()
    );
  }

  // Hàm khi bấm nút "Google"
  void _onLoginGoogleClicked() async {
    try {
      // View chỉ làm nhiệm vụ gọi cửa sổ đăng nhập của Google lên
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        // Lấy được Email/Tên rồi thì ném cho Presenter xử lý logic với SQLite
        _presenter.handleGoogleLogin(
            googleUser.email,
            googleUser.displayName ?? 'Google User'
        );
      }
    } catch (error) {
      onLoginError("Hủy đăng nhập hoặc lỗi Google: $error");
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView( // Thêm ScrollView để tránh lỗi tràn màn hình khi bật bàn phím
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("BeautyEyes", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              const SizedBox(height: 40),
              TextField(controller: _usernameController, decoration: const InputDecoration(labelText: "Tên đăng nhập", border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _passwordController, decoration: const InputDecoration(labelText: "Mật khẩu", border: OutlineInputBorder()), obscureText: true),
              const SizedBox(height: 20),

              // Nút Đăng nhập thường
              SizedBox(
                width: double.infinity,
                height: 45,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                    onPressed: _onLoginNormalClicked,
                    child: const Text("Đăng nhập", style: TextStyle(fontSize: 16))
                ),
              ),

              TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                  child: const Text("Chưa có tài khoản? Đăng ký ngay")
              ),
              const Divider(height: 40),

              // Nút Đăng nhập Google
              SizedBox(
                width: double.infinity,
                height: 45,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.red),
                  label: const Text("Đăng nhập bằng Google", style: TextStyle(fontSize: 16)),
                  // Khóa nút nếu đang loading
                  onPressed: _isLoading ? null : _onLoginGoogleClicked,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}