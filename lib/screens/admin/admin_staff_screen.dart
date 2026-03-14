import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../presenters/admin/admin_staff_presenter.dart';

class AdminStaffScreen extends StatefulWidget {
  const AdminStaffScreen({super.key});

  @override
  State<AdminStaffScreen> createState() => _AdminStaffScreenState();
}

class _AdminStaffScreenState extends State<AdminStaffScreen>
    implements AdminStaffView {
  late AdminStaffPresenter _presenter;
  List<User> _users = [];
  bool _isLoading = false;

  final Color bgColor = const Color(0xFFEAF4FF);
  final Color cardColor = const Color(0xFFF8FBFF);
  final Color primaryColor = const Color(0xFF2F6BFF);
  final Color titleColor = const Color(0xFF163A70);
  final Color iconColor = const Color(0xFF244E8F);

  @override
  void initState() {
    super.initState();
    _presenter = AdminStaffPresenter(this);
    _presenter.loadStaff();
  }

  @override
  void showStaff(List<User> users) {
    setState(() {
      _users = users;
    });
  }

  @override
  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void showLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void hideLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  void _confirmDelete(int userId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có muốn xóa staff này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _presenter.deleteStaff(userId);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showStaffForm({User? user}) {
    final usernameController = TextEditingController(text: user?.username ?? '');
    final passwordController = TextEditingController();
    final fullNameController = TextEditingController(text: user?.fullName ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');

    String selectedRole =
    (user?.role == 'ADMIN' || user?.role == 'STAFF') ? user!.role : 'STAFF';
    String selectedStatus = user?.status.isNotEmpty == true ? user!.status : 'ACTIVE';

    final isEdit = user != null;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: Text(isEdit ? 'Cập nhật staff' : 'Thêm staff'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 340,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: isEdit
                              ? 'Mật khẩu mới (để trống nếu không đổi)'
                              : 'Password',
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'Họ tên',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                          DropdownMenuItem(value: 'STAFF', child: Text('STAFF')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setLocalState(() {
                              selectedRole = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'ACTIVE', child: Text('ACTIVE')),
                          DropdownMenuItem(value: 'INACTIVE', child: Text('INACTIVE')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setLocalState(() {
                              selectedStatus = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final username = usernameController.text.trim();
                    final password = passwordController.text.trim();
                    final fullName = fullNameController.text.trim();
                    final email = emailController.text.trim();

                    if (username.isEmpty ||
                        fullName.isEmpty ||
                        email.isEmpty ||
                        (!isEdit && password.isEmpty)) {
                      showMessage('Vui lòng nhập đầy đủ thông tin');
                      return;
                    }

                    Navigator.pop(context);

                    if (isEdit) {
                      await _presenter.updateStaff(
                        userId: user.id!,
                        username: username,
                        fullName: fullName,
                        email: email,
                        role: selectedRole,
                        status: selectedStatus,
                        newPassword: password.isEmpty ? null : password,
                      );
                    } else {
                      await _presenter.addStaff(
                        username: username,
                        password: password,
                        fullName: fullName,
                        email: email,
                        role: selectedRole,
                        status: selectedStatus,
                      );
                    }
                  },
                  child: Text(isEdit ? 'Cập nhật' : 'Thêm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color _roleColor(String role) {
    return role.toUpperCase() == 'ADMIN'
        ? const Color(0xFFEF5350)
        : const Color(0xFFFFA726);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () => _showStaffForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manage Staff',
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          final displayName =
          user.fullName.isEmpty ? user.username : user.fullName;

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('@${user.username} • ${user.email}'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _roleColor(user.role).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          user.role,
                          style: TextStyle(
                            color: _roleColor(user.role),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () => _showStaffForm(user: user),
                      icon: Icon(Icons.edit_outlined, color: primaryColor),
                    ),
                    IconButton(
                      onPressed: () => _confirmDelete(user.id!),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}