import 'package:flutter/material.dart';
import '../models/user.dart';
import '../presenters/profile_presenter.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'order_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> implements ProfileView {
  late ProfilePresenter _presenter;
  late User _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _presenter = ProfilePresenter(this);
    _currentUser = widget.user;
  }

  @override
  void showLoading() => setState(() => _isLoading = true);
  @override
  void hideLoading() => setState(() => _isLoading = false);

  @override
  void onLogoutSuccess() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  void onError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  // Khối giao diện cho từng dòng Menu
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

  // Khối giao diện cho từng dòng thông tin User
  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Colors.blueGrey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
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
            // --- 1. KHU VỰC HEADER (Chỉ hiện Avatar và Tên chính) ---
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
                  Text(_currentUser.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- 2. KHU VỰC THÔNG TIN CHI TIẾT CỦA USER ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Thông tin cá nhân", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                  const Divider(height: 30, thickness: 1),

                  _buildInfoRow(Icons.badge_outlined, "Tên đăng nhập", _currentUser.username),
                  const SizedBox(height: 15),

                  _buildInfoRow(Icons.email_outlined, "Email", _currentUser.email.isNotEmpty ? _currentUser.email : "Chưa cập nhật"),
                  const SizedBox(height: 15),

                  _buildInfoRow(Icons.phone_outlined, "Số điện thoại", _currentUser.phone.isNotEmpty ? _currentUser.phone : "Chưa cập nhật"),
                  const SizedBox(height: 15),

                  _buildInfoRow(Icons.location_on_outlined, "Địa chỉ", _currentUser.address.isNotEmpty ? _currentUser.address : "Chưa cập nhật"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- 3. KHU VỰC MENU QUẢN LÝ ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  // Nút Chỉnh sửa thông tin
                  _buildMenuItem(Icons.edit_outlined, "Chỉnh sửa thông tin", onTap: () async {
                    final updatedUser = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfileScreen(user: _currentUser))
                    );
                    if (updatedUser != null && updatedUser is User) {
                      setState(() {
                        _currentUser = updatedUser;
                      });
                    }
                  }),
                  const Divider(height: 1, indent: 60),

                  // Nút Lịch sử đơn hàng
                  _buildMenuItem(Icons.shopping_bag_outlined, "Lịch sử đơn hàng", onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OrderHistoryScreen(user: _currentUser))
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- 4. NÚT ĐĂNG XUẤT ---
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
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Đăng xuất"),
                          content: const Text("Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy", style: TextStyle(color: Colors.grey))),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _presenter.logout();
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