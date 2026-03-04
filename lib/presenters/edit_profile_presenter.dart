import '../models/user.dart';
import '../db/database_helper.dart';

abstract class EditProfileView {
  void showLoading();
  void hideLoading();
  void onUpdateSuccess(User updatedUser);
  void onError(String message);
}

class EditProfilePresenter {
  final EditProfileView _view;
  EditProfilePresenter(this._view);

  void updateUserInfo(User user) async {
    _view.showLoading();
    try {
      await DatabaseHelper.instance.updateUser(user);
      _view.hideLoading();
      _view.onUpdateSuccess(user);
    } catch (e) {
      _view.hideLoading();
      _view.onError("Lỗi cập nhật thông tin: $e");
    }
  }
}