import '../models/user.dart';
import '../db/database_helper.dart';

// 1. BẢN HỢP ĐỒNG (CONTRACT) CHO VIEW
// Chứa các hành động mà Giao diện (View) bắt buộc phải làm được
abstract class RegisterView {
  void showLoading();
  void hideLoading();
  void onRegisterSuccess();
  void onRegisterError(String message);
}

// 2. LỚP TƯƠNG TÁC (PRESENTER)
// Xử lý logic và ra lệnh cho View
class RegisterPresenter {
  final RegisterView _view; // Giữ tham chiếu đến giao diện

  RegisterPresenter(this._view);

  // Hàm xử lý logic đăng ký
  void handleRegister(User newUser) async {
    _view.showLoading(); // Ra lệnh cho View hiện vòng xoay chờ

    // Gọi Model (Database)
    int result = await DatabaseHelper.instance.registerUser(newUser);

    _view.hideLoading(); // Ra lệnh cho View tắt vòng xoay

    // Kiểm tra kết quả và báo lại cho View
    if (result != -1) {
      _view.onRegisterSuccess();
    } else {
      _view.onRegisterError("Tên đăng nhập hoặc Email đã tồn tại.");
    }
  }
}