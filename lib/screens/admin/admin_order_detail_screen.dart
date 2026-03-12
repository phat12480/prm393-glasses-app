import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/admin/admin_order_detail_item.dart';
import '../../presenters/admin/admin_order_detail_presenter.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final int orderId;

  const AdminOrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen>
    implements AdminOrderDetailView {
  late AdminOrderDetailPresenter _presenter;

  bool _isLoading = false;
  Map<String, dynamic>? _header;
  List<AdminOrderDetailItem> _items = [];

  final Color bgColor = const Color(0xFFEAF4FF);
  final Color cardColor = const Color(0xFFF8FBFF);
  final Color primaryColor = const Color(0xFF2F6BFF);
  final Color titleColor = const Color(0xFF163A70);
  final Color iconColor = const Color(0xFF244E8F);

  final NumberFormat _currencyFormat = NumberFormat('#,##0', 'vi_VN');

  @override
  void initState() {
    super.initState();
    _presenter = AdminOrderDetailPresenter(this);
    _presenter.loadOrderDetail(widget.orderId);
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

  @override
  void showOrderHeader(Map<String, dynamic> header) {
    setState(() {
      _header = header;
    });
  }

  @override
  void showOrderItems(List<AdminOrderDetailItem> items) {
    setState(() {
      _items = items;
    });
  }

  @override
  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatMoney(double value) {
    return '${_currencyFormat.format(value)} đ';
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

  Widget _buildHeaderInfo() {
    final h = _header!;
    final customerName =
    ((h['full_name'] ?? '').toString().isNotEmpty)
        ? (h['full_name'] ?? '').toString()
        : (h['username'] ?? '').toString();

    final status = (h['status'] ?? '').toString();
    final totalAmount = (h['total_amount'] as num?)?.toDouble() ?? 0;

    return Column(
      children: [
        Container(
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
                    Text(
                      'Đơn hàng #${h['order_id']}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customerName.isEmpty ? 'Không rõ khách hàng' : customerName,
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
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
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
          child: Column(
            children: [
              _infoRow('Khách hàng', customerName),
              _infoRow('Email', (h['email'] ?? '').toString()),
              _infoRow('Ngày đặt', (h['order_date'] ?? '').toString()),
              _infoRow('Thanh toán', (h['payment_method'] ?? 'COD').toString()),
              Row(
                children: [
                  Text(
                    'Trạng thái: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _statusColor(status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Tổng tiền: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  Text(
                    _formatMoney(totalAmount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Không có' : value,
              style: TextStyle(color: titleColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(AdminOrderDetailItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F0FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: item.productImage.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                item.productImage,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.image_not_supported_outlined,
                  color: Color(0xFF2F6BFF),
                ),
              ),
            )
                : const Icon(
              Icons.image_outlined,
              color: Color(0xFF2F6BFF),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 6),
                if (item.lensName.isNotEmpty)
                  Text(
                    'Lens: ${item.lensName}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7A90),
                    ),
                  ),
                if (item.selectedColor.isNotEmpty)
                  Text(
                    'Màu: ${item.selectedColor}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7A90),
                    ),
                  ),
                const SizedBox(height: 6),
                Text(
                  'Số lượng: ${item.quantity}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7A90),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatMoney(item.itemTotalPrice),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
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
          'Order Detail',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _header == null
          ? Center(
        child: Text(
          'Không có dữ liệu đơn hàng',
          style: TextStyle(
            fontSize: 16,
            color: titleColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderInfo(),
            const SizedBox(height: 18),
            Text(
              'Sản phẩm trong đơn',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 12),
            if (_items.isEmpty)
              Text(
                'Đơn hàng chưa có sản phẩm',
                style: TextStyle(
                  fontSize: 14,
                  color: titleColor,
                ),
              )
            else
              ..._items.map(_buildItemCard),
          ],
        ),
      ),
    );
  }
}