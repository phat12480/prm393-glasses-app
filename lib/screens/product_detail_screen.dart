import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../presenters/product_detail_presenter.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final User user;

  const ProductDetailScreen({super.key, required this.product, required this.user});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> implements ProductDetailView {
  late ProductDetailPresenter _presenter;
  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _presenter = ProductDetailPresenter(this); // Khởi tạo Presenter
  }

  // --- THỰC THI HỢP ĐỒNG MVP ---
  @override
  void showLoading() => setState(() => _isLoading = true);

  @override
  void hideLoading() => setState(() => _isLoading = false);

  @override
  void onAddToCartSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Đã thêm vào giỏ hàng thành công!"),
            backgroundColor: Colors.green
        )
    );
  }

  @override
  void onError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red)
    );
  }

  // --- CÁC HÀM XỬ LÝ NÚT BẤM ---
  void _handleAddToCart() {
    _presenter.addToCart(widget.user, widget.product);
  }

  void _handleBuyNow() {
    _presenter.addToCart(widget.user, widget.product);
    // TODO: Chuyển hướng sang màn hình Giỏ Hàng hoặc Thanh Toán
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chuyển sang trang thanh toán..."))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Màu nền xám nhạt
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Chi tiết sản phẩm", style: TextStyle(color: Colors.black)),
      ),

      // Sử dụng Stack để có thể ghim thanh nút bấm xuống đáy màn hình
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100), // Chừa chỗ cho thanh bottom
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Ảnh sản phẩm
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    image: DecorationImage(
                      // Nếu không có link ảnh thì hiển thị ảnh placeholder
                      image: widget.product.imageUrl.isNotEmpty
                          ? NetworkImage(widget.product.imageUrl)
                          : const NetworkImage('https://images.unsplash.com/photo-1577803645773-f96470509666?q=80&w=1000&auto=format&fit=crop') as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // 2. Khối Thông tin (Tên, Giá, Trạng thái)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  transform: Matrix4.translationValues(0.0, -20.0, 0.0), // Kéo khối này lên đè vào ảnh một chút
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.product.name,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: widget.product.stock > 0 ? Colors.green[50] : Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.product.stock > 0 ? "Còn hàng" : "Hết hàng",
                              style: TextStyle(
                                  color: widget.product.stock > 0 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        formatCurrency.format(widget.product.price),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 20),

                      // 3. Khối Mô tả
                      const Text("Mô tả sản phẩm", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(
                        widget.product.description.isNotEmpty ? widget.product.description : "Đang cập nhật mô tả cho sản phẩm này.",
                        style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. Thanh Nút bấm (Ghim ở đáy)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: SafeArea( // Tránh vướng thanh điều hướng dưới đáy đt
                child: Row(
                  children: [
                    // Nút Thêm Giỏ Hàng
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(color: Colors.blueAccent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isLoading || widget.product.stock <= 0 ? null : _handleAddToCart,
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.add_shopping_cart, color: Colors.blueAccent),
                      ),
                    ),
                    const SizedBox(width: 15),

                    // Nút Mua Ngay
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: _isLoading || widget.product.stock <= 0 ? null : _handleBuyNow,
                        child: const Text("Mua Ngay", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}