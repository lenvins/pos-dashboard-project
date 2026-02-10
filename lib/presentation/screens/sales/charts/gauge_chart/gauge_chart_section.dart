import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_dashboard/core/utils/dimensions.dart';
import 'package:pos_dashboard/presentation/controllers/top_dashboard_controller.dart';
import 'gauge_chart_widget.dart';

class GaugeChartSection extends StatelessWidget {
  const GaugeChartSection({super.key});

  double calculatePercentage(double? value, double max) {
    if (value == null || max == 0) return 0;
    return ((value / max) * 100).clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TopDashboardController>(
      builder: (controller) {
        final model = controller.topDashboardModel;
        final maxGrossSales = model?.grossSales ?? 0.0;
        final maxSalesToday = model?.salesToday ?? 0.0;

        return Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              GaugeChartWidget(
                title: 'Receipts',
                percentage: model?.receipts?.toDouble() ?? 0,
                value: model?.receipts?.toDouble() ?? 0,
                color: const Color(0xFFFFA726),
                changePercentage: 35,
                sizeFactor: 0.8,
              ),
              SizedBox(width: Dimensions.width20),
              GaugeChartWidget(
                title: 'Sales Today',
                percentage: calculatePercentage(
                  model?.salesToday,
                  maxGrossSales,
                ),
                value: model?.salesToday ?? 0,
                color: const Color(0xFF66BB6A),
                changePercentage: 21,
                sizeFactor: 0.8,
              ),
              SizedBox(width: Dimensions.width20),
              GaugeChartWidget(
                title: 'Gross Sales',
                percentage: 100,
                value: model?.grossSales ?? 0,
                color: const Color(0xFF00308F),
                changePercentage: -9,
                sizeFactor: 0.8,
              ),
            ],
          ),
        );
      },
    );
  }
}
