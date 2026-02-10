import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_dashboard/core/utils/dimensions.dart';
import 'package:pos_dashboard/presentation/controllers/item_controller.dart';
import 'package:pos_dashboard/core/utils/app_constants.dart';
import 'package:pos_dashboard/data/models/items_model.dart'; // Import the Items model

class ItemsList extends StatefulWidget {
  final String listType;

  const ItemsList({super.key, this.listType = 'inventory'});

  @override
  _ItemsListState createState() => _ItemsListState();
}

class _ItemsListState extends State<ItemsList> {
  final ItemController itemController = Get.find<ItemController>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await itemController.getItemList();
  }

  List<Items> getItems() {
    if (itemController.itemList.isEmpty) {
      return [];
    }

    switch (widget.listType) {
      case 'critical_level':
        return itemController.itemList
            .where((item) => item.currentStock! > 0 && item.currentStock! < 5)
            .toList();

      case 'out_of_stock':
        return itemController.itemList
            .where((item) => item.currentStock == 0)
            .toList();

      case 'inventory':
      default:
        return itemController.itemList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(
      builder: (controller) {
        List<Items> items = getItems();

        return items.isEmpty
            ? Center(
              child: Text(
                "No items found",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
            : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                var item = items[index];
                return Card(
                  margin: EdgeInsets.symmetric(
                    horizontal: Dimensions.width16,
                    vertical: Dimensions.height8,
                  ),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(Dimensions.height16),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).cardColor,
                      child: Icon(
                        Icons.inventory_2,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                    title: Text(
                      item.itemName ?? 'Unknown Item',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: Dimensions.height8),
                        Text(
                          'Stock: ${item.currentStock ?? 0}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          'Price: ₱${item.price?.toStringAsFixed(2) ?? '0.00'}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: EdgeInsets.all(Dimensions.height8),
                      decoration: BoxDecoration(
                        color: _getStockStatusColor(
                          context,
                          item.currentStock ?? 0,
                        ),
                        borderRadius: BorderRadius.circular(
                          Dimensions.radius15,
                        ),
                      ),
                      child: Text(
                        _getStockStatus(item.currentStock ?? 0),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
      },
    );
  }

  Color _getStockStatusColor(BuildContext context, int stock) {
    if (stock == 0) {
      return Colors.red;
    } else if (stock < 5) {
      return Colors.orange;
    } else {
      return Theme.of(context).primaryColor;
    }
  }

  String _getStockStatus(int stock) {
    if (stock == 0) {
      return 'Out of Stock';
    } else if (stock < 5) {
      return 'Critical';
    } else {
      return 'In Stock';
    }
  }
}
