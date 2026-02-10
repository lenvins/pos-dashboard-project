import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:pos_dashboard/core/utils/dimensions.dart';

class GaugeChartWidget extends StatelessWidget {
  final String title;
  final double percentage;
  final double value;
  final Color color;
  final double changePercentage;
  final double sizeFactor;

  const GaugeChartWidget({
    super.key,
    required this.title,
    required this.percentage,
    required this.value,
    required this.color,
    required this.changePercentage,
    required this.sizeFactor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: Dimensions.height50 * sizeFactor,
          lineWidth: 8.0,
          animation: true,
          percent: (percentage / 100).clamp(0.0, 1.0),
          center: Text(
            value.toStringAsFixed(0),
            style: TextStyle(fontSize: Dimensions.font16, fontWeight: FontWeight.bold),
          ),
          progressColor: color,
          backgroundColor: color.withOpacity(0.2),
          circularStrokeCap: CircularStrokeCap.round,
        ),
        SizedBox(height: Dimensions.height10),
        Text(
          title,
          style: TextStyle(fontSize: Dimensions.font14, fontWeight: FontWeight.w600),
        ),
        Text(
          "${changePercentage.toStringAsFixed(0)}%",
          style: TextStyle(
            fontSize: Dimensions.font14,
            fontWeight: FontWeight.bold,
            color: changePercentage >= 0 ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}
