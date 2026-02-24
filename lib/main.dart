import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  // Dòng này bắt buộc phải có khi ứng dụng có sử dụng SQLite (DatabaseHelper)
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const BeautyEyesApp());
}

class BeautyEyesApp extends StatelessWidget {
  const BeautyEyesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeautyEyes Store',
      debugShowCheckedModeBanner: false, // Tắt dải băng "DEBUG" ở góc màn hình
      theme: ThemeData(
        // Cài đặt màu chủ đạo cho toàn bộ app (Màu xanh dương đậm)
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
        useMaterial3: true,
      ),
      // Trỏ màn hình khởi động đầu tiên về LoginScreen
      home: const LoginScreen(),
    );
  }
}