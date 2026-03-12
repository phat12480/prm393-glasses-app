import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/admin/admin_order_item.dart';
import '../../presenters/admin/admin_order_presenter.dart';
import 'admin_order_detail_screen.dart';

class AdminOrderScreen extends StatefulWidget {
  const AdminOrderScreen({super.key});

  @override
  State<AdminOrderScreen> createState() => _AdminOrderScreenState();
}

class _AdminOrderScreenState extends State<AdminOrderScreen>
    implements AdminOrderView {
  late AdminOrderPresenter _presenter;
  List<AdminOrderItem> _orders = [];
  bool _isLoading = false;

  final Color bgColor = const Color(0xFFEAF4FF);
  final Color cardColor = const Color(0xFFF8FBFF);
  final Color primaryColor = const Color(0xFF2F6BFF);
  final Color titleColor = const Color(0xFF163A70);
  final Color iconColor = const Color(0xFF244E8F);

  final NumberFormat _currencyFormat = NumberFormat('#,##0', 'vi_VN');

  @override
  void initState() {
    super.initState();
    _presenter = AdminOrderPresenter(this);
    _presenter.loadOrders();
  }

  @override
  void showOrders(List<AdminOrderItem> orders) {
    setState(() {
      _orders = orders;
    });
  }

  @override
  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void showLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void hideLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'CART':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatMoney(double value) {
    return '${_currencyFormat.format(value)} đ';
  }

  void _showStatusDialog(AdminOrderItem order) {
    String selectedStatus = order.status.isEmpty ? 'PENDING' : order.status;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text(
                'Cập nhật trạng thái',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Trạng thái đơn',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'CART', child: Text('CART')),
                  DropdownMenuItem(value: 'PENDING', child: Text('PENDING')),
                  DropdownMenuItem(value: 'COMPLETED', child: Text('COMPLETED')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setLocalState(() {
                      selectedStatus = value;
                    });
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _presenter.updateOrderStatus(
                      orderId: order.id,
                      status: selectedStatus,
                    );
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(int orderId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text(
          'Xác nhận',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Bạn có muốn xóa đơn hàng này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _presenter.deleteOrder(orderId);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(AdminOrderItem order) {
    final safeDate = order.orderDate.isEmpty
        ? 'Không có ngày'
        : order.orderDate.substring(
      0,
      order.orderDate.length >= 10 ? 10 : order.orderDate.length,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminOrderDetailScreen(orderId: order.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFD9E9FF),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F0FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '#${order.id}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.customerName.isEmpty
                        ? 'Không rõ khách hàng'
                        : order.customerName,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    safeDate,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7A90),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatMoney(order.totalAmount),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(order.status).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          order.status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _statusColor(order.status),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F2FF),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          order.paymentMethod.isEmpty
                              ? 'COD'
                              : order.paymentMethod,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: titleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () => _showStatusDialog(order),
                    icon: Icon(
                      Icons.edit_outlined,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () => _confirmDelete(order.id),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manage Order',
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(Icons.receipt_long_outlined, color: iconColor, size: 30),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6AA8FF), Color(0xFFAED1FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.all(Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.receipt_long_outlined,
                    color: Color(0xFF2F6BFF),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Danh sách đơn hàng',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tổng số: ${_orders.length} đơn',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _orders.isEmpty
                ? Center(
              child: Text(
                'Chưa có dữ liệu đơn hàng',
                style: TextStyle(
                  fontSize: 16,
                  color: titleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return _buildOrderCard(order);
              },
            ),
          ),
        ],
      ),
    );
  }
}