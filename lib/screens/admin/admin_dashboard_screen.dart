import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/revenue_data.dart';
import '../../presenters/admin/admin_dashboard_presenter.dart';
import '../login_screen.dart';
import 'admin_revenue_screen.dart';
import 'admin_user_screen.dart';
import 'admin_staff_screen.dart';
import 'admin_order_screen.dart';
import 'admin_product_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final User admin;

  const AdminDashboardScreen({
    super.key,
    required this.admin,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    implements AdminDashboardView {
  late AdminDashboardPresenter _presenter;
  List<Map<String, String>> _items = [];
  RevenueData? _revenueData;

  final Color bgColor = const Color(0xFFEAF4FF);
  final Color cardColor = const Color(0xFFF8FBFF);
  final Color primaryColor = const Color(0xFF2F6BFF);
  final Color titleColor = const Color(0xFF163A70);
  final Color iconColor = const Color(0xFF244E8F);

  @override
  void initState() {
    super.initState();
    _presenter = AdminDashboardPresenter(this);
    _presenter.loadMenuItems();
    _presenter.loadDashboardCharts();
  }

  @override
  void showMenuItems(List<Map<String, String>> items) {
    setState(() {
      _items = items;
    });
  }

  @override
  void showRevenueData(RevenueData data) {
    setState(() {
      _revenueData = data;
    });
  }

  @override
  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _navigateTo(String route) {
    if (route == '/admin/revenue') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminRevenueScreen()),
      );
    } else if (route == '/admin/users') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminUserScreen()),
      );
    } else if (route == '/admin/staff') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminStaffScreen()),
      );
    } else if (route == '/admin/orders') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminOrderScreen()),
      );
    } else if (route == '/admin/products') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminProductScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chức năng $route chưa làm')),
      );
    }
  }

  void _navigateFromDrawer(String route) {
    Navigator.pop(context);
    Future.microtask(() {
      _navigateTo(route);
    });
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFFF4F9FF),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF5D9CFF), Color(0xFF9CC8FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.admin_panel_settings_outlined,
                      size: 34,
                      color: Color(0xFF2F6BFF),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.admin.fullName.isEmpty ? 'Admin' : widget.admin.fullName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Username: ${widget.admin.username}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Email: ${widget.admin.email.isEmpty ? "Không có" : widget.admin.email}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Role: ${widget.admin.role}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard_outlined, color: iconColor),
              title: const Text('Admin Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.bar_chart_outlined, color: iconColor),
              title: const Text('Static Revenue'),
              onTap: () => _navigateFromDrawer('/admin/revenue'),
            ),
            ListTile(
              leading: Icon(Icons.badge_outlined, color: iconColor),
              title: const Text('Manage Staff'),
              onTap: () => _navigateFromDrawer('/admin/staff'),
            ),
            ListTile(
              leading: Icon(Icons.people_outline, color: iconColor),
              title: const Text('Manage User'),
              onTap: () => _navigateFromDrawer('/admin/users'),
            ),
            ListTile(
              leading: Icon(Icons.receipt_long_outlined, color: iconColor),
              title: const Text('Manage Order'),
              onTap: () => _navigateFromDrawer('/admin/orders'),
            ),
            ListTile(
              leading: Icon(Icons.inventory_2_outlined, color: iconColor),
              title: const Text('Manage Product'),
              onTap: () => _navigateFromDrawer('/admin/products'),
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Log out',
                style: TextStyle(color: Colors.red),
              ),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getMenuIcon(String route) {
    switch (route) {
      case '/admin/revenue':
        return Icons.bar_chart_rounded;
      case '/admin/staff':
        return Icons.badge_outlined;
      case '/admin/users':
        return Icons.people_alt_outlined;
      case '/admin/orders':
        return Icons.receipt_long_outlined;
      case '/admin/products':
        return Icons.inventory_2_outlined;
      default:
        return Icons.dashboard_customize_outlined;
    }
  }

  Widget _miniBar(String label, double value, double maxValue) {
    final ratio = maxValue == 0 ? 0.0 : value / maxValue;
    final height = math.max(36.0, ratio * 100).toDouble();

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              value.toInt().toString(),
              style: const TextStyle(fontSize: 8),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              height: height,
              decoration: BoxDecoration(
                color: const Color(0xFF67D0D5),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniRevenueCharts() {
    final pieItems = _revenueData?.pieData ?? [];
    final barItems = _revenueData?.barData ?? [];
    final pieTotal = pieItems.fold<double>(0, (sum, item) => sum + item.value);
    final maxBarValue = _revenueData?.maxBarValue ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thống kê nhanh',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _revenueData?.pieTitle ?? 'Doanh thu theo loại sản phẩm',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 12),
              pieItems.isEmpty
                  ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Chưa có dữ liệu')),
              )
                  : Row(
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CustomPaint(
                      painter: _MiniPieChartPainter(
                        pieItems
                            .map((e) => _MiniSlice(e.color, e.value))
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: pieItems.map((item) {
                        final percent =
                        pieTotal == 0 ? 0.0 : (item.value / pieTotal) * 100;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _LegendItem(
                            color: item.color,
                            label: item.label,
                            value: '${percent.toStringAsFixed(1)}%',
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _revenueData?.barTitle ?? 'Doanh thu 7 ngày gần nhất',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 14),
              barItems.isEmpty
                  ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Chưa có dữ liệu')),
              )
                  : SizedBox(
                height: 150,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: barItems
                      .map((item) => _miniBar(item.label, item.value, maxBarValue))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: Icon(
              Icons.account_circle_outlined,
              color: iconColor,
              size: 30,
            ),
          ),
        ),
        title: Text(
          'Admin dashboard',
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                      Icons.admin_panel_settings_outlined,
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
                          'Xin chào, ${widget.admin.fullName.isEmpty ? "Admin" : widget.admin.fullName}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Quản lý hệ thống BeautyEyes',
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 18,
                  childAspectRatio: 0.88,
                ),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final title = item['title'] ?? '';
                  final route = item['route'] ?? '';

                  return InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => _navigateTo(route),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(22),
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 14,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F0FF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                _getMenuIcon(route),
                                color: primaryColor,
                                size: 26,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: titleColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: _buildMiniRevenueCharts(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniSlice {
  final Color color;
  final double value;

  _MiniSlice(this.color, this.value);
}

class _MiniPieChartPainter extends CustomPainter {
  final List<_MiniSlice> slices;

  _MiniPieChartPainter(this.slices);

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<double>(0, (sum, item) => sum + item.value);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);

    double start = -math.pi / 2;

    for (final slice in slices) {
      final sweep = (slice.value / total) * 2 * math.pi;
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        true,
        paint,
      );

      start += sweep;
    }

    final holePaint = Paint()
      ..color = const Color(0xFFF8FBFF)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.42, holePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}