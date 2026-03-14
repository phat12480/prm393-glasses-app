import '../../db/database_helper.dart';
import '../../models/user.dart';

abstract class AdminStaffView {
  void showStaff(List<User> users);
  void showMessage(String message);
  void showLoading();
  void hideLoading();
}

class AdminStaffPresenter {
  final AdminStaffView view;

  AdminStaffPresenter(this.view);

  Future<void> loadStaff() async {
    try {
      view.showLoading();

      final result = await DatabaseHelper.instance.getStaffUsersForAdmin();

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

      view.showStaff(users);
    } catch (e) {
      view.showMessage('Lỗi tải danh sách staff: $e');
    } finally {
      view.hideLoading();
    }
  }

  Future<void> addStaff({
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

      view.showMessage('Thêm staff thành công');
      await loadStaff();
    } catch (e) {
      view.showMessage('Thêm staff thất bại: $e');
    }
  }

  Future<void> updateStaff({
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

      view.showMessage('Cập nhật staff thành công');
      await loadStaff();
    } catch (e) {
      view.showMessage('Cập nhật staff thất bại: $e');
    }
  }

  Future<void> deleteStaff(int userId) async {
    try {
      await DatabaseHelper.instance.deleteUserByAdmin(userId);
      view.showMessage('Xóa staff thành công');
      await loadStaff();
    } catch (e) {
      view.showMessage('Xóa staff thất bại: $e');
    }
  }
}