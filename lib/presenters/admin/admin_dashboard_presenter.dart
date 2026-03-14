import 'package:flutter/material.dart';
import '../../db/database_helper.dart';
import '../../models/revenue_data.dart';

abstract class AdminDashboardView {
  void showMenuItems(List<Map<String, String>> items);
  void showRevenueData(RevenueData data);
  void showMessage(String message);
}

class AdminDashboardPresenter {
  final AdminDashboardView view;

  AdminDashboardPresenter(this.view);

  void loadMenuItems() {
    final items = [
      {
        'title': 'Static\nrevenue',
        'route': '/admin/revenue',
      },
      {
        'title': 'Manage\nStaff',
        'route': '/admin/staff',
      },
      {
        'title': 'Manage\nUser',
        'route': '/admin/users',
      },
      {
        'title': 'Manage\nOrder',
        'route': '/admin/orders',
      },
      {
        'title': 'Manage\nProduct',
        'route': '/admin/products',
      },
    ];

    view.showMenuItems(items);
  }

  Future<void> loadDashboardCharts() async {
    try {
      final categoryRows = await DatabaseHelper.instance.getRevenueByCategory();
      final dayRows = await DatabaseHelper.instance.getRevenueLast7Days();

      const chartColors = [
        Color(0xFF67D0D5),
        Color(0xFF49B3D1),
        Color(0xFF348FBC),
        Color(0xFF6AA8FF),
      ];

      final pieData = categoryRows.asMap().entries.map((entry) {
        final index = entry.key;
        final row = entry.value;

        return RevenueSliceData(
          label: (row['category_type'] ?? '').toString(),
          value: (row['revenue'] as num?)?.toDouble() ?? 0,
          color: chartColors[index % chartColors.length],
        );
      }).where((e) => e.value > 0).toList();

      final reversedDays = dayRows.reversed.toList();
      final barData = reversedDays.map((row) {
        final day = (row['day'] ?? '').toString();
        String label = day;
        if (day.length >= 10) {
          label = day.substring(8, 10);
        }

        return RevenueBarData(
          label: label,
          value: (row['revenue'] as num?)?.toDouble() ?? 0,
        );
      }).toList();

      double maxBarValue = 0;
      for (final item in barData) {
        if (item.value > maxBarValue) {
          maxBarValue = item.value;
        }
      }

      final revenueData = RevenueData(
        pieTitle: 'Doanh thu theo loại sản phẩm',
        barTitle: 'Doanh thu 7 ngày gần nhất',
        pieData: pieData,
        barData: barData,
        maxBarValue: maxBarValue,
      );

      view.showRevenueData(revenueData);
    } catch (e) {
      view.showMessage('Lỗi tải dữ liệu chart dashboard: $e');
    }
  }
}