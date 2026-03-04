import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../presenters/order_history_presenter.dart';

class OrderHistoryScreen extends StatefulWidget {
  final User user;
  const OrderHistoryScreen({super.key, required this.user});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> implements OrderHistoryView {
  late OrderHistoryPresenter _presenter;
  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _presenter = OrderHistoryPresenter(this);
    _presenter.loadOrderHistory(widget.user.id!);
  }

  @override
  void showLoading() => setState(() => _isLoading = true);
  @override
  void hideLoading() => setState(() => _isLoading = false);

  @override
  void onLoadSuccess(List<Map<String, dynamic>> orders) => setState(() => _orders = orders);

  @override
  void onError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  // Chuyển đổi trạng thái sang Tiếng Việt
  String _translateStatus(String status) {
    if (status == 'PENDING') return 'Chờ xử lý';
    if (status == 'COMPLETED') return 'Đã giao hàng';
    return status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lịch sử đơn hàng"), backgroundColor: const Color(0xFF56CCF2)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? const Center(child: Text("Bạn chưa có đơn hàng nào.", style: TextStyle(fontSize: 16, color: Colors.grey)))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          // Format lại ngày tháng cho đẹp
          DateTime date = DateTime.parse(order['order_date']);
          String formattedDate = DateFormat('dd/MM/yyyy - HH:mm').format(date);

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const CircleAvatar(backgroundColor: Colors.blueAccent, child: Icon(Icons.receipt_long, color: Colors.white)),
              title: Text("Đơn hàng #${order['order_id']}", style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text("Ngày đặt: $formattedDate"),
                  const SizedBox(height: 5),
                  Text("Trạng thái: ${_translateStatus(order['status'])}", style: TextStyle(color: order['status'] == 'PENDING' ? Colors.orange : Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
              trailing: Text(formatCurrency.format(order['total_amount'] ?? 0), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          );
        },
      ),
    );
  }
}