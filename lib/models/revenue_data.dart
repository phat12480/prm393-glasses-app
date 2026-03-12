import 'package:flutter/material.dart';

class RevenueSliceData {
  final String label;
  final double value;
  final Color color;

  RevenueSliceData({
    required this.label,
    required this.value,
    required this.color,
  });
}

class RevenueBarData {
  final String label;
  final double value;

  RevenueBarData({
    required this.label,
    required this.value,
  });
}

class RevenueData {
  final String pieTitle;
  final String barTitle;
  final List<RevenueSliceData> pieData;
  final List<RevenueBarData> barData;
  final double maxBarValue;

  RevenueData({
    required this.pieTitle,
    required this.barTitle,
    required this.pieData,
    required this.barData,
    required this.maxBarValue,
  });
}