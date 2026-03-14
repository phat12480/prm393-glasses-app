import '../db/database_helper.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../services/momo_service.dart';

abstract class CheckoutView {
  void showLoading();
  void hideLoading();
  void onCheckoutSuccess();
  void onError(String message);
  void openMoMoPayment(String payUrl, int userId);
}

class CheckoutPresenter {
  final CheckoutView _view;

  CheckoutPresenter(this._view);

  // Xử lý khi người dùng bấm "XÁC NHẬN ĐẶT HÀNG" / "THANH TOÁN MOMO"
  void processCheckout(
      User user,
      double totalAmount,
      String paymentMethod,
      String name,
      String phone,
      String address,
      String note,
      {
        Product? directProduct,
        int? directQuantity,
        String? directColor,
        int? directLensId
      }
      ) async {
    _view.showLoading();
    try {
      // 1. Cập nhật thông tin giao hàng mới nhất vào Database cho User
      User updatedUser = User(
        id: user.id,
        username: user.username,
        password: user.password,
        email: user.email,
        role: user.role,
        fullName: name,
        phone: phone,
        address: address,
      );
      await DatabaseHelper.instance.updateUser(updatedUser);

      // 2. Xử lý phương thức thanh toán
      if (paymentMethod == 'MOMO') {
        String? payUrl = await MoMoService.createPaymentUrl(totalAmount, "ThanhToan_BeautyEyes");
        _view.hideLoading();
        if (payUrl != null) {
          _view.openMoMoPayment(payUrl, user.id!);
        } else {
          _view.onError("Không thể khởi tạo thanh toán MoMo lúc này!");
        }
      }
      // 3. Thanh toán khi nhận hàng (COD)
      else {
        if (directProduct != null) {
          // NẾU LÀ MUA NGAY: Tạo đơn trực tiếp
          await DatabaseHelper.instance.createDirectOrder(
              user.id!,
              paymentMethod,
              directProduct.id!,
              directLensId,
              directColor,
              directQuantity!,
              directProduct.price
          );
        } else {
          // NẾU LÀ MUA TỪ GIỎ HÀNG: Chốt giỏ hàng
          await DatabaseHelper.instance.checkoutCart(user.id!, paymentMethod);
        }
        _view.hideLoading();
        _view.onCheckoutSuccess();
      }
    } catch (e) {
      _view.hideLoading();
      _view.onError("Lỗi hệ thống: $e");
    }
  }

  // Chốt đơn vào Database sau khi MoMo trả về kết quả quét mã thành công
  void confirmMoMoPayment(
      int userId,
      {
        Product? directProduct,
        int? directQuantity,
        String? directColor,
        int? directLensId
      }
      ) async {
    _view.showLoading();
    try {
      if (directProduct != null) {
        // Chốt đơn Mua Ngay
        await DatabaseHelper.instance.createDirectOrder(
            userId,
            'MOMO',
            directProduct.id!,
            directLensId,
            directColor,
            directQuantity!,
            directProduct.price
        );
      } else {
        // Chốt đơn Giỏ Hàng
        await DatabaseHelper.instance.checkoutCart(userId, 'MOMO');
      }
      _view.hideLoading();
      _view.onCheckoutSuccess();
    } catch (e) {
      _view.hideLoading();
      _view.onError("Lỗi chốt đơn MoMo: $e");
    }
  }
}