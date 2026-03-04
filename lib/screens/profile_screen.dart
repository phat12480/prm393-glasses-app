import 'package:flutter/material.dart';
import '../models/user.dart';
import '../presenters/profile_presenter.dart';
import 'login_screen.dart'; // Cần import Login để quay về khi đăng xuất

class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> implements ProfileView {
  late ProfilePresenter _presenter;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _presenter = ProfilePresenter(this);
  }

  // --- THỰC THI HỢP ĐỒNG MVP ---
  @override
  void showLoading() => setState(() => _isLoading = true);

  @override
  void hideLoading() => setState(() => _isLoading = false);

  @override
  void onLogoutSuccess() {
    // Xóa toàn bộ lịch sử màn hình và đẩy về trang Đăng nhập
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  void onError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  // --- UI COMPONENTS ---
  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap, Color color = Colors.black87}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color skyBlue = Color(0xFF56CCF2);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: skyBlue,
        elevation: 0,
        title: const Text("Hồ sơ của tôi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. KHU VỰC HEADER (AVATAR & TÊN) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 30, top: 20),
              decoration: const BoxDecoration(
                color: skyBlue,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 60, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 15),
                  Text(widget.user.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 5),
                  Text(widget.user.email, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- 2. KHU VỰC MENU QUẢN LÝ ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  _buildMenuItem(Icons.person_outline, "Chỉnh sửa thông tin", onTap: () {}),
                  const Divider(height: 1, indent: 60),
                  _buildMenuItem(Icons.shopping_bag_outlined, "Đơn hàng của tôi", onTap: () {}),
                  const Divider(height: 1, indent: 60),
                  _buildMenuItem(Icons.location_on_outlined, "Sổ địa chỉ", onTap: () {}),
                  const Divider(height: 1, indent: 60),
                  _buildMenuItem(Icons.settings_outlined, "Cài đặt", onTap: () {}),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- 3. NÚT ĐĂNG XUẤT ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    foregroundColor: Colors.redAccent,
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text("Đăng Xuất", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    // Hiển thị hộp thoại xác nhận
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Đăng xuất"),
                          content: const Text("Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy", style: TextStyle(color: Colors.grey))),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Đóng Dialog
                                  _presenter.logout(); // Gọi hàm Đăng xuất
                                },
                                child: const Text("Đăng xuất", style: TextStyle(color: Colors.red))
                            ),
                          ],
                        )
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}