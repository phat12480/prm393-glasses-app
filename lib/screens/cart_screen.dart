import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../presenters/cart_presenter.dart';

class CartScreen extends StatefulWidget {
  final User user;
  const CartScreen({super.key, required this.user});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> implements CartView {
  late CartPresenter _presenter;
  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  bool _isLoading = true;
  bool _isEmpty = false;
  List<Map<String, dynamic>> _cartItems = [];
  double _totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _presenter = CartPresenter(this);
    _presenter.loadCart(widget.user.id!); // Tải giỏ hàng khi mở màn hình
  }

  // --- THỰC THI MVP ---
  @override
  void showLoading() => setState(() => _isLoading = true);

  @override
  void hideLoading() => setState(() => _isLoading = false);

  @override
  void onLoadCartSuccess(List<Map<String, dynamic>> items, double totalPrice) {
    setState(() {
      _cartItems = items;
      _totalPrice = totalPrice;
      _isEmpty = false;
    });
  }

  @override
  void onCartEmpty() {
    setState(() {
      _cartItems = [];
      _totalPrice = 0;
      _isEmpty = true;
    });
  }

  @override
  void onCheckoutSuccess() {
    // Hiện thông báo và quay về trang chủ
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text("Đặt hàng thành công!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Cảm ơn bạn đã mua sắm tại BeautyEyes.", textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Đóng Dialog
                Navigator.pop(context); // Quay về Home
              },
              child: const Text("Về Trang Chủ"),
            )
          ],
        ),
      ),
    );
  }

  @override
  void onError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  // --- UI COMPONENT ---
  Widget _buildCartItem(Map<String, dynamic> item) {
    int quantity = item['quantity'];
    double itemTotalPrice = item['item_total_price'];
    double unitPrice = itemTotalPrice / quantity; // Tính ngược lại đơn giá 1 sản phẩm
    int stock = item['product_stock'] ?? 100; // Số lượng tồn kho

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Căn lên Top để UI cân đối hơn
          children: [
            // Ảnh sản phẩm
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 80, height: 80,
                color: const Color(0xFFF3F6F8),
                child: item['product_image'] != null && item['product_image'].toString().isNotEmpty
                    ? Image.network(item['product_image'], fit: BoxFit.cover)
                    : const Icon(Icons.remove_red_eye, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
            // Thông tin sản phẩm
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['product_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),

                  // BỘ CHỌN SỐ LƯỢNG NẰM NGAY DƯỚI TÊN SẢN PHẨM
                  Container(
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Để khung tự ôm sát nút
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          icon: const Icon(Icons.remove, size: 16),
                          onPressed: quantity > 1
                              ? () => _presenter.updateQuantity(item['order_item_id'], quantity - 1, unitPrice, widget.user.id!)
                              : null,
                        ),
                        Container(
                          width: 30,
                          color: Colors.grey.shade100,
                          alignment: Alignment.center,
                          // ĐÃ BỎ CHỮ "x", CHỈ CÒN SỐ
                          child: Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          icon: const Icon(Icons.add, size: 16),
                          onPressed: quantity < stock
                              ? () => _presenter.updateQuantity(item['order_item_id'], quantity + 1, unitPrice, widget.user.id!)
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (item['selected_color'] != null)
                    Text("Màu: ${item['selected_color']}", style: const TextStyle(color: Colors.blueGrey, fontSize: 13)),
                  if (item['lens_name'] != null)
                    Text("+ ${item['lens_name']}", style: const TextStyle(color: Colors.orange, fontSize: 13, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 4),

                  // Giá tiền nằm riêng một dòng dưới cùng
                  Text(formatCurrency.format(itemTotalPrice), style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
            ),
            // Nút Xóa (Thùng rác)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Xóa sản phẩm"),
                      content: const Text("Bạn có chắc muốn xóa sản phẩm này khỏi giỏ hàng?"),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy", style: TextStyle(color: Colors.grey))),
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _presenter.removeItem(item['order_item_id'], widget.user.id!);
                            },
                            child: const Text("Xóa", style: TextStyle(color: Colors.red))
                        ),
                      ],
                    )
                );
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text("Giỏ hàng của tôi"), backgroundColor: const Color(0xFF56CCF2)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            const Text("Giỏ hàng trống", style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                onPressed: () => Navigator.pop(context),
                child: const Text("Tiếp tục mua sắm")
            )
          ],
        ),
      )
          : Column(
        children: [
          // Danh sách sản phẩm
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                return _buildCartItem(_cartItems[index]);
              },
            ),
          ),
          // Thanh tổng tiền & Thanh toán
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20))
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("TỔNG TIỀN:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                      Text(formatCurrency.format(_totalPrice), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _presenter.checkout(widget.user.id!),
                      child: const Text("THANH TOÁN NGAY", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}