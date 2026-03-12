import '../../db/database_helper.dart';
import '../../models/admin/admin_menu_item.dart';
import '../../models/admin/admin_dashboard_chart_data.dart';

abstract class AdminDashboardView {
  void showMenuItems(List<AdminMenuItem> items);
  void showChartData({
    required List<AdminDashboardPieItem> pieItems,
    required List<AdminDashboardBarItem> barItems,
  });
  void showMessage(String message);
}

class AdminDashboardPresenter {
  final AdminDashboardView view;

  AdminDashboardPresenter(this.view);

  void loadMenuItems() {
    final items = [
      AdminMenuItem(title: 'Static\nrevenue', route: '/admin/revenue'),
      AdminMenuItem(title: 'Manage\nStaff', route: '/admin/staff'),
      AdminMenuItem(title: 'Manage\nUser', route: '/admin/users'),
      AdminMenuItem(title: 'Manage\nOrder', route: '/admin/orders'),
      AdminMenuItem(title: 'Manage\nProduct', route: '/admin/products'),
    ];

    view.showMenuItems(items);
  }

  Future<void> loadDashboardCharts() async {
    try {
      final categoryRows = await DatabaseHelper.instance.getRevenueByCategory();
      final dayRows = await DatabaseHelper.instance.getRevenueLast7Days();

      final pieItems = categoryRows.map((row) {
        return AdminDashboardPieItem(
          label: (row['category_type'] ?? '').toString(),
          value: (row['revenue'] as num?)?.toDouble() ?? 0,
        );
      }).where((e) => e.value > 0).toList();

      final reversedDays = dayRows.reversed.toList();
      final barItems = reversedDays.map((row) {
        final day = (row['day'] ?? '').toString();
        String label = day;
        if (day.length >= 10) {
          label = day.substring(8, 10);
        }

        return AdminDashboardBarItem(
          label: label,
          value: (row['revenue'] as num?)?.toDouble() ?? 0,
        );
      }).toList();

      view.showChartData(
        pieItems: pieItems,
        barItems: barItems,
      );
    } catch (e) {
      view.showMessage('Lỗi tải dữ liệu chart dashboard: $e');
    }
  }
}