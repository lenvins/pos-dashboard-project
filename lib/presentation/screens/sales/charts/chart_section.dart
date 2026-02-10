import 'package:flutter/material.dart';
import 'package:pos_dashboard/core/utils/dimensions.dart';
import 'package:pos_dashboard/presentation/screens/sales/sales_details_page.dart';
import 'package:pos_dashboard/presentation/screens/sales/charts/gauge_chart/gauge_chart_section.dart';
import 'package:pos_dashboard/presentation/screens/sales/charts/bar_chart/bar_chart_section.dart';

class ChartSection extends StatelessWidget {
  const ChartSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SalesDetailsPage()),
          ),
      child: Container(
        padding: EdgeInsets.all(Dimensions.width16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: Dimensions.height10),
              child: Text(
                'SALES SUMMARY',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            SizedBox(height: Dimensions.height20),
            const GaugeChartSection(),
            SizedBox(height: Dimensions.height20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Dimensions.height10),
                const BarChartSection(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
