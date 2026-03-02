import 'package:flutter/material.dart';
import 'package:pos_dashboard/core/utils/dimensions.dart';

class MainSalesWidget extends StatelessWidget {
  final String itemName;
  final double quantity;
  final Widget? itemImage;

  const MainSalesWidget({
    super.key,
    required this.itemName,
    required this.quantity,
    this.itemImage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: Dimensions.height12,
        horizontal: Dimensions.width16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (itemImage != null)
                CircleAvatar(
                  radius: Dimensions.radius15,
                  backgroundColor: Theme.of(context).cardColor,
                  child: ClipOval(
                    child: SizedBox(
                      width: Dimensions.width30,
                      height: Dimensions.height30,
                      child: itemImage,
                    ),
                  ),
                ),
              if (itemImage != null) SizedBox(width: Dimensions.width10),
              Text(itemName, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          Text(
            quantity.toString(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
