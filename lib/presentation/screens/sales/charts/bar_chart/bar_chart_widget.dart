import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pos_dashboard/core/utils/dimensions.dart';

class BarChartWidget extends StatelessWidget {
  final List<DateTime> dates;
  final List<double> values;
  final DateTime selectedDate;
  final int currentHour;

  const BarChartWidget({
    super.key,
    required this.dates,
    required this.values,
    required this.selectedDate,
    required this.currentHour,
  });

  String _getHourLabel(int hour) {
    if (hour < 0) hour = 24 + hour;
    hour = hour % 24;
    String period = hour >= 12 ? 'PM' : 'AM';
    int displayHour = hour % 12;
    if (displayHour == 0) displayHour = 12;
    return '$displayHour$period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.height12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: Dimensions.height6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          maxY:
              values.isEmpty
                  ? 100
                  : values.reduce((a, b) => a > b ? a : b) * 1.2,
          minY: 0,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBorder: BorderSide(color: Theme.of(context).dividerColor),
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                int hour = (currentHour - 1 + groupIndex) % 24;
                return BarTooltipItem(
                  '${_getHourLabel(hour)}\n₱${rod.toY.toStringAsFixed(2)}',
                  TextStyle(
                    color:
                        Theme.of(context).textTheme.bodyLarge?.color ??
                        Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  int hour = (currentHour - 1 + value.toInt()) % 24;
                  return Text(
                    _getHourLabel(hour),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '₱${value.toInt()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval:
                values.isEmpty || values.every((v) => v == 0)
                    ? 20
                    : max(values.reduce((a, b) => a > b ? a : b) / 5, 1),
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).dividerColor.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Theme.of(context).dividerColor.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            3,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: index < values.length ? values[index] : 0,
                  color:
                      index == 1
                          ? const Color(0xFF00308F)
                          : const Color(0xFF00308F).withOpacity(0.5),
                  width: 40,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
