import 'package:flutter/material.dart';
import '../../db/database_helper.dart';
import '../../models/revenue_data.dart';

abstract class AdminRevenueView {
  void showLoading();
  void hideLoading();
  void showRevenueData(RevenueData data);
  void showSummary({
    required double totalRevenue,
    required int totalOrders,
    required int totalCustomers,
  });
  void showError(String message);
}

class AdminRevenuePresenter {
  final AdminRevenueView view;

  AdminRevenuePresenter(this.view);

  Future<void> loadRevenueData() async {
    try {
      view.showLoading();

      final summary = await DatabaseHelper.instance.getRevenueSummary();
      final categoryRows = await DatabaseHelper.instance.getRevenueByCategory();
      final dayRows = await DatabaseHelper.instance.getRevenueLast7Days();

      final totalRevenue = (summary['totalRevenue'] as num).toDouble();
      final totalOrders = (summary['totalOrders'] as num).toInt();
      final totalCustomers = (summary['totalCustomers'] as num).toInt();

      view.showSummary(
        totalRevenue: totalRevenue,
        totalOrders: totalOrders,
        totalCustomers: totalCustomers,
      );

      final List<RevenueSliceData> pieData = [];
      final colors = [
        const Color(0xFF67D0D5),
        const Color(0xFF49B3D1),
        const Color(0xFF348FBC),
      ];

      for (int i = 0; i < categoryRows.length; i++) {
        final row = categoryRows[i];
        final type = (row['category_type'] ?? 'OTHER').toString();
        final revenue = (row['revenue'] as num?)?.toDouble() ?? 0;

        pieData.add(
          RevenueSliceData(
            label: type,
            value: revenue,
            color: colors[i % colors.length],
          ),
        );
      }

      final reversedDays = dayRows.reversed.toList();
      final List<RevenueBarData> barData = reversedDays.map((row) {
        final day = (row['day'] ?? '').toString();
        final revenue = (row['revenue'] as num?)?.toDouble() ?? 0;

        String label = day;
        if (day.length >= 10) {
          label = day.substring(8, 10);
        }

        return RevenueBarData(
          label: label,
          value: revenue,
        );
      }).toList();

      double maxBarValue = 0;
      for (final item in barData) {
        if (item.value > maxBarValue) {
          maxBarValue = item.value;
        }
      }

      if (maxBarValue == 0) {
        maxBarValue = 1;
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
      view.showError('Không thể tải dữ liệu doanh thu: $e');
    } finally {
      view.hideLoading();
    }
  }
}