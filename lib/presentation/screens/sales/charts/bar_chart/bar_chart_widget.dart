import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pos_dashboard/core/utils/dimensions.dart';

class BarChartWidget extends StatelessWidget {
  final List<double> values;
  static const Color currentHourColor = Color(0xFF1565C0);
  static const Color highestIncomeColor = Color(0xFF2E7D32);
  static const Color lowestIncomeColor = Color(0xFFC62828);
  static const Color otherHourColor = Color(0xFF616161);

  const BarChartWidget({
    super.key,
    required this.values,
  });

  String _getHourLabel(int hour) {
    if (hour < 0) {
      hour = 24 + hour;
    }
    hour = hour % 24;
    final String period = hour >= 12 ? 'PM' : 'AM';
    int displayHour = hour % 12;
    if (displayHour == 0) {
      displayHour = 12;
    }
    return '$displayHour$period';
  }

  @override
  Widget build(BuildContext context) {
    final double maxValue =
        values.isEmpty ? 0.0 : values.reduce((a, b) => a > b ? a : b);
    final double minValue =
        values.isEmpty ? 0.0 : values.reduce((a, b) => a < b ? a : b);
    final int currentHourIndex =
        values.isEmpty ? -1 : DateTime.now().hour % values.length;
    final bool hasRange = values.isNotEmpty && maxValue > minValue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.height12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: Dimensions.height6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          groupsSpace: 8,
          maxY: maxValue == 0 ? 100 : maxValue * 1.2,
          minY: 0,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBorder: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final int hour = group.x.toInt() % 24;
                return BarTooltipItem(
                  '${_getHourLabel(hour)}\nPHP ${rod.toY.toStringAsFixed(2)}',
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
                interval: 1,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final int hour = value.toInt();
                  if (hour < 0 || hour >= values.length) {
                    return const SizedBox.shrink();
                  }

                  return SideTitleWidget(
                    meta: meta,
                    space: 6,
                    child: Text(
                      _getHourLabel(hour),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
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
                    'PHP ${value.toInt()}',
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
                    : max(maxValue / 5, 1),
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            values.length,
            (index) {
              final value = values[index];
              Color barColor = otherHourColor;

              if (index == currentHourIndex) {
                barColor = currentHourColor;
              } else if (hasRange && value == maxValue) {
                barColor = highestIncomeColor;
              } else if (hasRange && value == minValue) {
                barColor = lowestIncomeColor;
              }

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: value,
                    color: barColor,
                    width: 18,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
