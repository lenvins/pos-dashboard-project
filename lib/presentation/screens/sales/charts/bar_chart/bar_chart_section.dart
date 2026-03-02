import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_dashboard/presentation/controllers/top_dashboard_controller.dart';
import 'bar_chart_widget.dart';

class BarChartSection extends StatefulWidget {
  const BarChartSection({super.key});

  @override
  State<BarChartSection> createState() => _BarChartSectionState();
}

class _BarChartSectionState extends State<BarChartSection> {
  final ScrollController _chartScrollController = ScrollController();

  Widget _buildLegendItem({
    required BuildContext context,
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  List<double> _parseHourlyData(String? barchartData) {
    if (barchartData == null || barchartData.trim().isEmpty) {
      return List.filled(24, 0.0);
    }

    final values = barchartData.split(',');
    if (values.length < 24) {
      return [
        ...values.map((v) => double.tryParse(v.trim()) ?? 0.0),
        ...List.filled(24 - values.length, 0.0),
      ];
    }
    return values
        .take(24)
        .map((v) => double.tryParse(v.trim()) ?? 0.0)
        .toList();
  }

  @override
  void dispose() {
    _chartScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TopDashboardController>(
      builder: (controller) {
        final allHourlyValues = _parseHourlyData(controller.barchartPerHour);
        final chartWidth = allHourlyValues.length * 56.0;

        return SizedBox(
          height: 340,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 6,
                children: [
                  _buildLegendItem(
                    context: context,
                    color: BarChartWidget.currentHourColor,
                    label: 'Current Hour',
                  ),
                  _buildLegendItem(
                    context: context,
                    color: BarChartWidget.highestIncomeColor,
                    label: 'Highest Income',
                  ),
                  _buildLegendItem(
                    context: context,
                    color: BarChartWidget.lowestIncomeColor,
                    label: 'Lowest Income',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Scrollbar(
                  controller: _chartScrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  interactive: true,
                  notificationPredicate:
                      (notification) =>
                          notification.metrics.axis == Axis.horizontal,
                  child: SingleChildScrollView(
                    controller: _chartScrollController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: chartWidth,
                      height: 280,
                      child: BarChartWidget(values: allHourlyValues),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
