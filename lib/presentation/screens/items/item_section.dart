import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_dashboard/core/utils/dimensions.dart';
import 'package:pos_dashboard/data/models/top_dashboard_model.dart';
import 'package:pos_dashboard/presentation/controllers/top_dashboard_controller.dart';
import 'package:pos_dashboard/presentation/screens/sales/main_sales_widget.dart';

class ItemsSection extends StatefulWidget {
  const ItemsSection({super.key});

  @override
  _ItemsSectionState createState() => _ItemsSectionState();
}

class _ItemsSectionState extends State<ItemsSection> {
  final TopDashboardController topDashboardController =
      Get.find<TopDashboardController>();

  @override
  void initState() {
    super.initState();
  }

  List<Top5Items> getItems() {
    if (topDashboardController.top5ItemsList.isEmpty) {
      return [];
    }

    return topDashboardController.top5ItemsList;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'ITEMS',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color:Theme.of(context).primaryColor,
              ),
            ),
          ),
          SizedBox(height: Dimensions.height10),
          GetBuilder<TopDashboardController>(
            builder: (controller) {
              List<Top5Items> items = getItems();
              if (controller.top5ItemsList.isEmpty) {
                return Center(
                  child: Text(
                    "No items found",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }

              List<Top5Items> topItems = List.from(controller.top5ItemsList);
              topItems.sort(
                (a, b) => (b.grossSales ?? 0).compareTo(a.grossSales ?? 0),
              );
              topItems = topItems.take(3).toList();

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topItems.length,
                separatorBuilder:
                    (context, index) =>
                        Divider(color: Theme.of(context).dividerColor),
                itemBuilder: (context, index) {
                  var item = topItems[index];
                  String itemName = item.itemName ?? "Unknown Item";
                  if (itemName.length > 20) {
                    itemName = '${itemName.substring(0, 20)}...';
                  }

                  double quantity = item.grossSales ?? 0;

                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: Dimensions.height8),
                    child: MainSalesWidget(
                      itemName: itemName,
                      quantity: quantity,
                      itemImage: Icon(
                        Icons.inventory_2,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
