import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../presenters/admin/admin_user_presenter.dart';

class AdminUserScreen extends StatefulWidget {
  const AdminUserScreen({super.key});

  @override
  State<AdminUserScreen> createState() => _AdminUserScreenState();
}

class _AdminUserScreenState extends State<AdminUserScreen>
    implements AdminUserView {
  late AdminUserPresenter _presenter;
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
    _presenter = AdminUserPresenter(this);
    _presenter.loadUsers();
  }

  @override
  void showUsers(List<User> users) {
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text(
          'Xác nhận',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Bạn có muốn xóa user này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _presenter.deleteUser(userId);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showUserForm({User? user}) {
    final usernameController = TextEditingController(text: user?.username ?? '');
    final passwordController = TextEditingController();
    final fullNameController = TextEditingController(text: user?.fullName ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');

    String selectedRole = user?.role.isNotEmpty == true ? user!.role : 'CUSTOMER';
    String selectedStatus = user?.status.isNotEmpty == true ? user!.status : 'ACTIVE';

    final isEdit = user != null;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                isEdit ? 'Cập nhật user' : 'Thêm user',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
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
                      if (!isEdit)
                        TextField(
                          controller: passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          obscureText: true,
                        ),
                      if (isEdit)
                        TextField(
                          controller: passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Mật khẩu mới (để trống nếu không đổi)',
                            border: OutlineInputBorder(),
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
                          DropdownMenuItem(value: 'CUSTOMER', child: Text('CUSTOMER')),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
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
                      await _presenter.updateUser(
                        userId: user.id!,
                        username: username,
                        fullName: fullName,
                        email: email,
                        role: selectedRole,
                        status: selectedStatus,
                        newPassword: password.isEmpty ? null : password,
                      );
                    } else {
                      await _presenter.addUser(
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
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return const Color(0xFFEF5350);
      case 'STAFF':
        return const Color(0xFFFFA726);
      default:
        return const Color(0xFF42A5F5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () => _showUserForm(),
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
          'Manage User',
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(Icons.people_alt_outlined, color: iconColor, size: 30),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6AA8FF), Color(0xFFAED1FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.group_outlined,
                    color: Color(0xFF2F6BFF),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Danh sách người dùng',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tổng số: ${_users.length} user',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _users.isEmpty
                ? Center(
              child: Text(
                'Chưa có dữ liệu user',
                style: TextStyle(
                  fontSize: 16,
                  color: titleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                final displayName =
                user.fullName.isEmpty ? user.username : user.fullName;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFD9E9FF),
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x18000000),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F0FF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'U${user.id.toString().padLeft(3, '0')}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
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
                            Text(
                              '@${user.username} • ${user.email}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7A90),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _roleColor(user.role)
                                        .withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    user.role,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _roleColor(user.role),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: user.status.toUpperCase() == 'ACTIVE'
                                        ? Colors.green.withOpacity(0.12)
                                        : Colors.grey.withOpacity(0.16),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    user.status,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: user.status.toUpperCase() == 'ACTIVE'
                                          ? Colors.green
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F2FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () => _showUserForm(user: user),
                              icon: Icon(
                                Icons.edit_outlined,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () => _confirmDelete(user.id!),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}