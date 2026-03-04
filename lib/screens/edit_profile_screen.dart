import 'package:flutter/material.dart';
import '../models/user.dart';
import '../presenters/edit_profile_presenter.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> implements EditProfileView {
  late EditProfilePresenter _presenter;
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _presenter = EditProfilePresenter(this);
    // Điền sẵn thông tin cũ vào ô nhập
    _nameCtrl = TextEditingController(text: widget.user.fullName);
    _phoneCtrl = TextEditingController(text: widget.user.phone);
    _addressCtrl = TextEditingController(text: widget.user.address);
  }

  @override
  void showLoading() => setState(() => _isLoading = true);
  @override
  void hideLoading() => setState(() => _isLoading = false);

  @override
  void onUpdateSuccess(User updatedUser) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cập nhật thành công!"), backgroundColor: Colors.green));
    // Đóng trang và trả về user mới để ProfileScreen cập nhật giao diện
    Navigator.pop(context, updatedUser);
  }

  @override
  void onError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chỉnh sửa thông tin"), backgroundColor: const Color(0xFF56CCF2)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: "Họ và tên", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: "Số điện thoại", border: OutlineInputBorder()), keyboardType: TextInputType.phone),
            const SizedBox(height: 15),
            TextField(controller: _addressCtrl, decoration: const InputDecoration(labelText: "Địa chỉ giao hàng", border: OutlineInputBorder()), maxLines: 3),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                onPressed: _isLoading ? null : () {
                  // Tạo cục User mới với thông tin vừa sửa
                  User updatedUser = User(
                    id: widget.user.id,
                    username: widget.user.username,
                    password: widget.user.password,
                    email: widget.user.email, // Không cho sửa email/username
                    role: widget.user.role,
                    fullName: _nameCtrl.text.trim(),
                    phone: _phoneCtrl.text.trim(),
                    address: _addressCtrl.text.trim(),
                  );
                  _presenter.updateUserInfo(updatedUser);
                },
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("LƯU THAY ĐỔI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}