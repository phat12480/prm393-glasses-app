import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../presenters/checkout_presenter.dart';
import '../db/database_helper.dart';


class CheckoutScreen extends StatefulWidget {
  final User user;
  final double totalAmount;
  final Product? directProduct;
  final int? directQuantity;
  final String? directColor;
  final int? directLensId;

  const CheckoutScreen({super.key, required this.user, required this.totalAmount, this.directProduct, this.directQuantity, this.directColor, this.directLensId});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> implements CheckoutView {
  late CheckoutPresenter _presenter;
  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _noteCtrl;

  String _paymentMethod = 'COD'; // Mặc định là COD
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _presenter = CheckoutPresenter(this);

    // Đổ dữ liệu tạm thời từ widget.user
    _nameCtrl = TextEditingController(text: widget.user.fullName);
    _phoneCtrl = TextEditingController(text: widget.user.phone);
    _addressCtrl = TextEditingController(text: widget.user.address);
    _noteCtrl = TextEditingController();

    // GỌI HÀM LẤY DỮ LIỆU MỚI NHẤT
    _loadLatestUser();
  }

  // Hàm móc dữ liệu mới nhất từ SQLite lên Form
  void _loadLatestUser() async {
    User? latestUser = await DatabaseHelper.instance.getUserById(widget.user.id!);
    if (latestUser != null && mounted) {
      setState(() {
        _nameCtrl.text = latestUser.fullName;
        _phoneCtrl.text = latestUser.phone;
        _addressCtrl.text = latestUser.address;
      });
    }
  }

  @override
  void showLoading() => setState(() => _isLoading = true);
  @override
  void hideLoading() => setState(() => _isLoading = false);

  @override
  void onCheckoutSuccess() {
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
            const Text("Đơn hàng của bạn sẽ sớm được giao.", textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Xóa hết các trang giỏ hàng/thanh toán và về thẳng Trang Chủ
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("Về Trang Chủ"),
            )
          ],
        ),
      ),
    );
  }

  @override
  void openMoMoPayment(String payUrl, int userId) async {
    final Uri url = Uri.parse(payUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      onError("Không thể mở trình duyệt thanh toán!");
      return;
    }

    if (mounted) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Xác nhận thanh toán"),
            content: const Text("Bạn đã hoàn tất thanh toán trên MoMo chưa?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Chưa thanh toán", style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.pink, foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                    // TRUYỀN DỮ LIỆU MUA NGAY VÀO ĐÂY LUÔN
                    _presenter.confirmMoMoPayment(userId,
                      directProduct: widget.directProduct,
                      directQuantity: widget.directQuantity,
                      directColor: widget.directColor,
                      directLensId: widget.directLensId,
                    );
                  },
                  child: const Text("Đã thanh toán xong")
              ),
            ],
          )
      );
    }
  }

  @override
  void onError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text("Thanh toán"), backgroundColor: const Color(0xFF56CCF2)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. KHỐI THÔNG TIN GIAO HÀNG ---
              const Text("Thông tin giao hàng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Họ và tên", border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
                validator: (val) => val == null || val.isEmpty ? "Vui lòng nhập họ tên" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Số điện thoại", border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
                validator: (val) => val == null || val.isEmpty ? "Vui lòng nhập số điện thoại" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _addressCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: "Địa chỉ nhận hàng", border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
                validator: (val) => val == null || val.isEmpty ? "Vui lòng nhập địa chỉ" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _noteCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: "Ghi chú (Không bắt buộc)", border: OutlineInputBorder(), fillColor: Colors.white, filled: true),
              ),
              const SizedBox(height: 30),

              // --- 2. KHỐI PHƯƠNG THỨC THANH TOÁN ---
              const Text("Phương thức thanh toán", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text("Thanh toán khi nhận hàng (COD)", style: TextStyle(fontWeight: FontWeight.w500)),
                      value: 'COD',
                      groupValue: _paymentMethod,
                      activeColor: Colors.blueAccent,
                      onChanged: (val) => setState(() => _paymentMethod = val!),
                    ),
                    const Divider(height: 1),
                    RadioListTile<String>(
                      title: const Text("Thanh toán qua Ví MoMo", style: TextStyle(fontWeight: FontWeight.w500)),
                      value: 'MOMO',
                      groupValue: _paymentMethod,
                      activeColor: Colors.pink,
                      // ĐÃ SỬA: Bọc Image trong SizedBox để không bị lỗi tràn Tile Width
                      secondary: SizedBox(
                          width: 35,
                          height: 35,
                          child: Image.network("https://upload.wikimedia.org/wikipedia/vi/f/fe/MoMo_Logo.png", fit: BoxFit.contain)
                      ),
                      onChanged: (val) => setState(() => _paymentMethod = val!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- 3. KHỐI TỔNG TIỀN VÀ NÚT CHỐT ĐƠN ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("TỔNG TIỀN:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                  Text(formatCurrency.format(widget.totalAmount), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
                ],
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _paymentMethod == 'MOMO' ? Colors.pink : Colors.blueAccent, // Đổi màu nút theo phương thức
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _presenter.processCheckout(
                        widget.user, widget.totalAmount, _paymentMethod,
                        _nameCtrl.text.trim(), _phoneCtrl.text.trim(), _addressCtrl.text.trim(), _noteCtrl.text.trim(),
                        // TRUYỀN DỮ LIỆU MUA NGAY (Nếu có)
                        directProduct: widget.directProduct,
                        directQuantity: widget.directQuantity,
                        directColor: widget.directColor,
                        directLensId: widget.directLensId,
                      );
                    }
                  },
                  child: Text(
                      _paymentMethod == 'MOMO' ? "THANH TOÁN BẰNG MOMO" : "XÁC NHẬN ĐẶT HÀNG",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}