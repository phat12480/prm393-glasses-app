import '../models/product.dart';
import '../db/database_helper.dart';

// 1. HỢP ĐỒNG CHO VIEW
abstract class HomeView {
  void showLoading();
  void hideLoading();
  // Trả về một Map chứa danh sách sản phẩm theo từng loại
  void onLoadProductsSuccess(Map<String, List<Product>> categorizedProducts);
  void onLoadError(String message);
}

// 2. LỚP XỬ LÝ LOGIC (PRESENTER)
class HomePresenter {
  final HomeView _view;

  HomePresenter(this._view);

  // Hàm tải toàn bộ sản phẩm khi mới vào màn hình Home
  void loadAllProducts() async {
    _view.showLoading();

    try {
      // Tải song song cả 3 loại sản phẩm từ SQLite
      final readyProducts = await DatabaseHelper.instance.getProductsByType('READY');
      final frameProducts = await DatabaseHelper.instance.getProductsByType('FRAME');
      final lensProducts = await DatabaseHelper.instance.getProductsByType('LENS');

      // Gói gọn lại thành 1 Map và gửi về cho Giao diện
      final Map<String, List<Product>> result = {
        'READY': readyProducts,
        'FRAME': frameProducts,
        'LENS': lensProducts,
      };

      _view.hideLoading();
      _view.onLoadProductsSuccess(result);

    } catch (e) {
      _view.hideLoading();
      _view.onLoadError("Lỗi tải dữ liệu: $e");
    }
  }
}