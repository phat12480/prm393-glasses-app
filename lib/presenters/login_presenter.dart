import '../models/user.dart';
import '../db/database_helper.dart';

// 1. BẢN HỢP ĐỒNG (CONTRACT) CHO VIEW
abstract class LoginView {
  void showLoading();
  void hideLoading();
  void onLoginSuccess(User user);
  void onLoginError(String message);
}

// 2. LỚP TƯƠNG TÁC (PRESENTER)
class LoginPresenter {
  final LoginView _view;

  LoginPresenter(this._view);

  // Hàm xử lý đăng nhập bằng Username & Password
  void handleNormalLogin(String username, String password) async {
    // Validate cơ bản
    if (username.isEmpty || password.isEmpty) {
      _view.onLoginError("Vui lòng nhập đầy đủ tài khoản và mật khẩu!");
      return;
    }

    _view.showLoading(); // Bật vòng xoay chờ

    // Gọi xuống Database (Model)
    User? user = await DatabaseHelper.instance.login(username, password);

    _view.hideLoading(); // Tắt vòng xoay

    // Báo kết quả về cho Giao diện (View)
    if (user != null) {
      _view.onLoginSuccess(user);
    } else {
      _view.onLoginError("Sai tài khoản hoặc mật khẩu!");
    }
  }

  // Hàm xử lý đăng nhập bằng Google
  void handleGoogleLogin(String email, String fullName) async {
    _view.showLoading();

    try {
      // Đẩy dữ liệu Google xuống DB xử lý (Tạo mới hoặc lấy thông tin cũ)
      User user = await DatabaseHelper.instance.handleGoogleLogin(email, fullName);

      _view.hideLoading();
      _view.onLoginSuccess(user);
    } catch (e) {
      _view.hideLoading();
      _view.onLoginError("Lỗi kết nối cơ sở dữ liệu: $e");
    }
  }
}