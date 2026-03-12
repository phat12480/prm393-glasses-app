import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import '../../models/revenue_data.dart';
import '../../presenters/admin/admin_revenue_presenter.dart';

class AdminRevenueScreen extends StatefulWidget {
  const AdminRevenueScreen({super.key});

  @override
  State<AdminRevenueScreen> createState() => _AdminRevenueScreenState();
}

class _AdminRevenueScreenState extends State<AdminRevenueScreen>
    implements AdminRevenueView {
  late AdminRevenuePresenter _presenter;

  RevenueData? _revenueData;
  bool _isLoading = false;

  double _totalRevenue = 0;
  int _totalOrders = 0;
  int _totalCustomers = 0;

  final Color bgColor = const Color(0xFFEAF4FF);
  final Color cardColor = const Color(0xFFF8FBFF);
  final Color primaryColor = const Color(0xFF2F6BFF);
  final Color titleColor = const Color(0xFF163A70);
  final Color iconColor = const Color(0xFF244E8F);

  final NumberFormat _currencyFormat = NumberFormat('#,##0', 'vi_VN');

  @override
  void initState() {
    super.initState();
    _presenter = AdminRevenuePresenter(this);
    _presenter.loadRevenueData();
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
  void showRevenueData(RevenueData data) {
    setState(() {
      _revenueData = data;
    });
  }

  @override
  void showSummary({
    required double totalRevenue,
    required int totalOrders,
    required int totalCustomers,
  }) {
    setState(() {
      _totalRevenue = totalRevenue;
      _totalOrders = totalOrders;
      _totalCustomers = totalCustomers;
    });
  }

  @override
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatMoney(double value) {
    return '${_currencyFormat.format(value)} đ';
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconBg,
  }) {
    return Expanded(
      child: Container(
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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: primaryColor, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: titleColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: titleColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(List<RevenueSliceData> pieData) {
    final total = pieData.fold<double>(0, (sum, item) => sum + item.value);

    return Column(
      children: pieData.map((item) {
        final percent = total == 0 ? 0 : (item.value / total) * 100;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: titleColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${percent.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 13,
                  color: titleColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBarChart(RevenueData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
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
      child: SizedBox(
        height: 260,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: data.barData.map((item) {
            final ratio = item.value / data.maxBarValue;
            final double barHeight = math.max(12.0, ratio * 180).toDouble();

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _currencyFormat.format(item.value),
                      style: const TextStyle(fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: const Color(0xFF67D0D5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: titleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _revenueData;

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
          'Static Revenue',
          style: TextStyle(
            color: titleColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(Icons.bar_chart_rounded, color: iconColor, size: 30),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : data == null
          ? Center(
        child: Text(
          'Chưa có dữ liệu doanh thu',
          style: TextStyle(
            fontSize: 16,
            color: titleColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
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
                      Icons.show_chart,
                      color: Color(0xFF2F6BFF),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Thống kê doanh thu',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Dữ liệu lấy từ đơn hàng thực tế',
                          style: TextStyle(
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
            const SizedBox(height: 16),
            Row(
              children: [
                _buildSummaryCard(
                  icon: Icons.payments_outlined,
                  title: 'Tổng doanh thu',
                  value: _formatMoney(_totalRevenue),
                  iconBg: const Color(0xFFE3F0FF),
                ),
                const SizedBox(width: 12),
                _buildSummaryCard(
                  icon: Icons.receipt_long_outlined,
                  title: 'Số đơn hàng',
                  value: '$_totalOrders',
                  iconBg: const Color(0xFFE8F7FF),
                ),
                const SizedBox(width: 12),
                _buildSummaryCard(
                  icon: Icons.people_alt_outlined,
                  title: 'Khách mua hàng',
                  value: '$_totalCustomers',
                  iconBg: const Color(0xFFEAF6F1),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              data.pieTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
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
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: CustomPaint(
                      painter: _PieChartPainter(data.pieData),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildLegend(data.pieData),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(
              data.barTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildBarChart(data),
          ],
        ),
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<RevenueSliceData> slices;

  _PieChartPainter(this.slices);

  @override
  void paint(Canvas canvas, Size size) {
    if (slices.isEmpty) return;

    final total = slices.fold<double>(0, (sum, item) => sum + item.value);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);

    double startRadian = -math.pi / 2;

    for (final slice in slices) {
      final sweepRadian = (slice.value / total) * 2 * math.pi;

      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startRadian,
        sweepRadian,
        true,
        paint,
      );

      startRadian += sweepRadian;
    }

    final holePaint = Paint()
      ..color = const Color(0xFFF8FBFF)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.45, holePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}