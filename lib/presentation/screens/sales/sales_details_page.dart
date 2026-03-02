import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_dashboard/core/utils/dimensions.dart';
import 'package:pos_dashboard/presentation/controllers/top_dashboard_controller.dart';
import 'package:pos_dashboard/presentation/widgets/date_selector.dart';

class SalesDetailsPage extends StatefulWidget {
  const SalesDetailsPage({super.key});
  @override
  _SalesDetailsPageState createState() => _SalesDetailsPageState();
}

class _SalesDetailsPageState extends State<SalesDetailsPage> {
  DateTime _selectedDate = DateTime.now();
  late TopDashboardController _topDashboardController;
  int? _selectedStoreId;

  @override
  void initState() {
    super.initState();
    
    _topDashboardController = Get.find<TopDashboardController>();
    
    if (Get.arguments != null && Get.arguments['storeId'] != null) {
      _selectedStoreId = Get.arguments['storeId'];
      _refreshData();
    } else {
      _selectedStoreId = 1; 
      _refreshData();
    }
  }

  void _refreshData() {
    if (_selectedStoreId != null) {
      _topDashboardController.getTopList(
        date: _selectedDate,
        storeIds: [_selectedStoreId!],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sales Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GetBuilder<TopDashboardController>(
        builder: (controller) {
          final model = controller.topDashboardModel;

          return Padding(
            padding: EdgeInsets.all(Dimensions.height16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DateSelector(
                  selectedDate: _selectedDate,
                  onDateChanged: (newDate) {
                    setState(() {
                      _selectedDate = newDate;
                      _refreshData();
                    });
                  },
                ),
                SizedBox(height: Dimensions.height30),
                _buildDetailRow(
                  'Gross Sales',
                  model?.grossSales ?? 0.0,
                  isBold: true,
                ),
                SizedBox(height: Dimensions.height20),
                _buildDetailRow('Sales Today', model?.salesToday ?? 0.0),
                SizedBox(height: Dimensions.height20),
                _buildDetailRow('Receipts', (model?.receipts ?? 0).toDouble()),
                SizedBox(height: Dimensions.height20),
                _buildDetailRow('Refunds', model?.refunds ?? 0.0),
                Divider(color: Theme.of(context).dividerColor),
                SizedBox(height: Dimensions.height20),
                _buildDetailRow('Discounts', model?.discounts ?? 0.0),
                SizedBox(height: Dimensions.height20),
                _buildDetailRow('Cost of Goods', model?.costOfGoods ?? 0.0),
                Divider(color: Theme.of(context).dividerColor),
                SizedBox(height: Dimensions.height20),
                _buildDetailRow(
                  'Gross Profit',
                  model?.grossProfit ?? 0.0,
                  isBold: true,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, double value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              isBold
                  ? Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                  : Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          '₱${value.toStringAsFixed(2)}',
          style:
              isBold
                  ? Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                  : Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}