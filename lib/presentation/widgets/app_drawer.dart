import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_dashboard/presentation/controllers/store_controller.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                GetBuilder<StoreController>(
                  builder:
                      (storeController) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Store',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value: storeController.currentStore,
                              isExpanded: true,
                              dropdownColor: Theme.of(context).primaryColor,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: Colors.white),
                              underline: const SizedBox(),
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                              items:
                                  storeController.stores.map((String store) {
                                    return DropdownMenuItem<String>(
                                      value: store,
                                      child: Text(store),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  storeController.changeStore(newValue);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                ),
              ],
            ),
          ),
          // Add more drawer items here if needed
        ],
      ),
    );
  }
}
