import '../../db/database_helper.dart';
import '../../models/user.dart';

abstract class AdminUserView {
  void showUsers(List<User> users);
  void showMessage(String message);
  void showLoading();
  void hideLoading();
}

class AdminUserPresenter {
  final AdminUserView view;

  AdminUserPresenter(this.view);

  Future<void> loadUsers() async {
    try {
      view.showLoading();

      final result = await DatabaseHelper.instance.getCustomerUsersForAdmin();

      final users = result.map((e) {
        return User(
          id: e['user_id'] as int,
          username: (e['username'] ?? '').toString(),
          password: (e['password'] ?? '').toString(),
          fullName: (e['full_name'] ?? '').toString(),
          email: (e['email'] ?? '').toString(),
          phone: (e['phone'] ?? '').toString(),
          address: (e['address'] ?? '').toString(),
          role: (e['role'] ?? '').toString(),
          status: (e['status'] ?? 'ACTIVE').toString(),
        );
      }).toList();

      view.showUsers(users);
    } catch (e) {
      view.showMessage('Lỗi tải danh sách user: $e');
    } finally {
      view.hideLoading();
    }
  }

  Future<void> addUser({
    required String username,
    required String password,
    required String fullName,
    required String email,
    required String role,
    required String status,
  }) async {
    try {
      await DatabaseHelper.instance.addUserByAdmin(
        username: username,
        password: password,
        fullName: fullName,
        email: email,
        role: role,
        status: status,
      );

      view.showMessage('Thêm user thành công');
      await loadUsers();
    } catch (e) {
      view.showMessage('Thêm user thất bại: $e');
    }
  }

  Future<void> updateUser({
    required int userId,
    required String username,
    required String fullName,
    required String email,
    required String role,
    required String status,
    String? newPassword,
  }) async {
    try {
      await DatabaseHelper.instance.updateUserByAdmin(
        userId: userId,
        username: username,
        fullName: fullName,
        email: email,
        role: role,
        status: status,
        newPassword: newPassword,
      );

      view.showMessage('Cập nhật user thành công');
      await loadUsers();
    } catch (e) {
      view.showMessage('Cập nhật user thất bại: $e');
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      await DatabaseHelper.instance.deleteUserByAdmin(userId);
      view.showMessage('Xóa user thành công');
      await loadUsers();
    } catch (e) {
      view.showMessage('Xóa user thất bại: $e');
    }
  }
}