import 'package:google_sign_in/google_sign_in.dart';

// 1. HỢP ĐỒNG MVP CHO VIEW
abstract class ProfileView {
  void showLoading();
  void hideLoading();
  void onLogoutSuccess();
  void onError(String message);
}

// 2. LỚP XỬ LÝ LOGIC (PRESENTER)
class ProfilePresenter {
  final ProfileView _view;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  ProfilePresenter(this._view);

  // Xử lý Đăng xuất
  void logout() async {
    _view.showLoading();
    try {
      // Nếu người dùng đang đăng nhập bằng Google, tiến hành đăng xuất Google
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // (Nếu có dùng SharedPreferences để lưu token thì xóa ở đây)

      _view.hideLoading();
      _view.onLogoutSuccess();
    } catch (e) {
      _view.hideLoading();
      _view.onError("Lỗi khi đăng xuất: $e");
    }
  }
}