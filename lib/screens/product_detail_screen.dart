import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../models/product.dart';
import '../models/user.dart';
import '../presenters/product_detail_presenter.dart';
import 'cart_screen.dart';
import 'checkout_screen.dart';

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
  String? _selectedColor;
  int _cartItemCount = 0; // Biến Lưu số lượng giỏ hàng
  int _quantity = 1; // Khởi tạo số lượng mặc định là 1

  @override
  void initState() {
    super.initState();
    _presenter = ProductDetailPresenter(this);
    _presenter.loadCartCount(widget.user.id!); // Đếm giỏ hàng ngay khi vào trang
  }

  // --- THỰC THI HỢP ĐỒNG MVP ---
  @override
  void showLoading() => setState(() => _isLoading = true);

  @override
  void hideLoading() => setState(() => _isLoading = false);

  @override
  void onAddToCartSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã thêm vào giỏ hàng thành công!"), backgroundColor: Colors.green)
    );
    // Cập nhật lại số đếm ngay lập tức sau khi thêm hàng thành công
    _presenter.loadCartCount(widget.user.id!);
  }

  @override
  void onError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red)
    );
  }

  // Nhận số đếm từ Presenter để cập nhật Badge Giỏ hàng
  @override
  void onUpdateCartCount(int count) {
    if (mounted) {
      setState(() {
        _cartItemCount = count;
      });
    }
  }

  // Thực thi khi bấm mua ngay
  @override
  void onBuyNowSuccess(double totalAmount) async {
    await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CheckoutScreen(
          user: widget.user,
          totalAmount: totalAmount,
          // ĐÓNG GÓI SẢN PHẨM MANG THEO
          directProduct: widget.product,
          directQuantity: _quantity,
          directColor: _selectedColor,
        ))
    );
    // Nếu khách bấm nút quay lại (Back), ta load lại số lượng giỏ hàng cũ cho chắc
    _presenter.loadCartCount(widget.user.id!);
  }

  // --- HÀM XỬ LÝ MÀU SẮC ---
  List<String> _getAvailableColors() {
    if (widget.product.specs == null || widget.product.specs!.isEmpty) return [];
    try {
      final Map<String, dynamic> parsedSpecs = jsonDecode(widget.product.specs!);
      if (parsedSpecs.containsKey('colors')) { // Kiểm tra nếu có key colors thì sẽ parse
        return List<String>.from(parsedSpecs['colors']);
      }
    } catch (e) {
      print("Lỗi parse specs: $e");
    }
    return [];
  }

  // --- WIDGET HIỂN THỊ MÀU SẮC ---
  Widget _buildColorSelector() {
    final colors = _getAvailableColors();
    if (colors.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        const Text("Chọn màu sắc:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: colors.map((color) {
            final isSelected = _selectedColor == color;
            return ChoiceChip(
              label: Text(color),
              selected: isSelected,
              selectedColor: Colors.blueAccent.withOpacity(0.2),
              labelStyle: TextStyle(
                  color: isSelected ? Colors.blueAccent : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
              ),
              onSelected: (selected) {
                setState(() => _selectedColor = selected ? color : null);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- WIDGET CHỌN SỐ LƯỢNG ---
  Widget _buildQuantitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        const Text("Số lượng:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        // Khung chứa các nút cộng trừ
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Giúp khung ôm sát vào các nút
            children: [
              // Nút Trừ
              IconButton(
                icon: const Icon(Icons.remove, size: 20),
                onPressed: _quantity > 1
                    ? () => setState(() => _quantity--)
                    : null,
              ),
              // Hiển thị số lượng
              SizedBox(
                width: 30,
                child: Text('$_quantity', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              // Nút Cộng
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: _quantity < widget.product.stock
                    ? () => setState(() => _quantity++)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- CÁC HÀM XỬ LÝ NÚT BẤM ---
  // Add to cart
  void _handleAddToCart() {
    if (_getAvailableColors().isNotEmpty && _selectedColor == null) {
      onError("Vui lòng chọn màu sắc trước khi thêm vào giỏ hàng!");
      return;
    }
    _presenter.addToCart(widget.user, widget.product, color: _selectedColor, quantity: _quantity);
  }

  //Buy now
  void _handleBuyNow() {
    if (_getAvailableColors().isNotEmpty && _selectedColor == null) {
      onError("Vui lòng chọn màu sắc trước khi mua!");
      return;
    }
    // GỌI HÀM PRESENTER (Không lưu giỏ hàng)
    _presenter.buyNow(widget.product, _quantity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Chi tiết sản phẩm", style: TextStyle(color: Colors.black)),
        // Icon giỏ hàng
        actions: [
          Badge(
            label: Text('$_cartItemCount', style: const TextStyle(color: Colors.white)),
            isLabelVisible: _cartItemCount > 0,
            backgroundColor: Colors.redAccent,
            offset: const Offset(-5, 5),
            child: IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.black), // Icon màu đen cho hợp nền
                onPressed: () async {
                  // Mở trang giỏ hàng
                  await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartScreen(user: widget.user))
                  );
                  // Khi từ giỏ hàng quay lại trang này, đếm lại số hàng
                  _presenter.loadCartCount(widget.user.id!);
                }
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
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
                      image: widget.product.imageUrl.isNotEmpty
                          ? NetworkImage(widget.product.imageUrl)
                          : const NetworkImage('https://images.unsplash.com/photo-1577803645773-f96470509666?q=80&w=1000&auto=format&fit=crop') as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // 2. Khối Thông tin
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  transform: Matrix4.translationValues(0.0, -20.0, 0.0),
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
                              // CẬP NHẬT HIỂN THỊ SỐ TỒN KHO Ở ĐÂY
                              widget.product.stock > 0 ? "Kho: ${widget.product.stock}" : "Hết hàng",
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

                      // Hiển thị phần chọn màu (nếu có)
                      _buildColorSelector(),

                      // GỌI WIDGET CHỌN SỐ LƯỢNG VÀO ĐÂY (chỉ hiện nếu còn hàng)
                      if (widget.product.stock > 0) _buildQuantitySelector(),

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

          // 4. Thanh Nút bấm
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: SafeArea(
                child: Row(
                  children: [
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