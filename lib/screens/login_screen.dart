import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../db/database_helper.dart';
import '../models/user.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void _loginNormal() async {
    User? user = await DatabaseHelper.instance.login(
        _usernameController.text,
        _passwordController.text
    );

    if (user != null) {
      _navigateToHome(user);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sai tài khoản hoặc mật khẩu!")));
    }
  }

  void _loginWithGoogle() async {
    try {
      // Kích hoạt popup đăng nhập Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        // Lấy thông tin từ Google và đẩy vào SQLite
        User user = await DatabaseHelper.instance.handleGoogleLogin(
            googleUser.email,
            googleUser.displayName ?? 'Google User'
        );

        // GỌI HÀM KIỂM TRA TẠI ĐÂY
        // await DatabaseHelper.instance.printAllUsers();

        _navigateToHome(user);
      }
    } catch (error) {
      print("Lỗi đăng nhập Google: $error");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi đăng nhập Google")));
    }
  }

  void _navigateToHome(User user) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Xin chào, ${user.fullName}!")));

    // Điều hướng sang màn hình HomeScreen và truyền đối tượng user sang
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(user: user))
    );
  }

  //Giao diện login
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("BeautyEyes", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 40),
              TextField(controller: _usernameController, decoration: const InputDecoration(labelText: "Tên đăng nhập", border: OutlineInputBorder())),
              const SizedBox(height: 16),
              TextField(controller: _passwordController, decoration: const InputDecoration(labelText: "Mật khẩu", border: OutlineInputBorder()), obscureText: true),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _loginNormal, child: const Text("Đăng nhập")),
              ),
              TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                  child: const Text("Chưa có tài khoản? Đăng ký ngay")
              ),
              const Divider(height: 40),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.red),
                  label: const Text("Đăng nhập bằng Google"),
                  onPressed: _loginWithGoogle,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}