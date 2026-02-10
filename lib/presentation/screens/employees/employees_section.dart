import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:pos_dashboard/core/utils/dimensions.dart';
import 'package:pos_dashboard/data/models/top_dashboard_model.dart';
import 'package:pos_dashboard/presentation/controllers/theme_controller.dart';
import 'package:pos_dashboard/presentation/controllers/top_dashboard_controller.dart';
import 'package:pos_dashboard/presentation/screens/sales/main_sales_widget.dart';
import 'package:pos_dashboard/presentation/screens/settings/settings_screen.dart';

class EmployeesSection extends StatefulWidget {
  const EmployeesSection({super.key});

  @override
  _EmployeesSectionState createState() => _EmployeesSectionState();
}

class _EmployeesSectionState extends State<EmployeesSection> {
  final TopDashboardController topDashboardController =
      Get.find<TopDashboardController>();

  @override
  void initState() {
    super.initState();
  }

  List<Top5Employees> getEmployees() {
    if (topDashboardController.top5EmployeesList.isEmpty) {
      return [];
    }

    return topDashboardController.top5EmployeesList;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();

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
              'EMPLOYEES',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          SizedBox(height: Dimensions.height10),
          GetBuilder<TopDashboardController>(
            builder: (controller) {
              List<Top5Employees> employees = getEmployees();
              if (controller.top5EmployeesList.isEmpty) {
                return Center(
                  child: Text(
                    "No items found",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }

              List<Top5Employees> topEmployees = List.from(
                controller.top5EmployeesList,
              );
              topEmployees.sort(
                (a, b) => (b.grossSales ?? 0).compareTo(a.grossSales ?? 0),
              );
              topEmployees = topEmployees.take(3).toList();

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topEmployees.length,
                separatorBuilder:
                    (context, index) =>
                        Divider(color: Theme.of(context).dividerColor),
                itemBuilder: (context, index) {
                  var employees = topEmployees[index];

                  String employeeName =
                      employees.employeeName ?? "Unknown Item";
                  if (employeeName.length > 20) {
                    employeeName = '${employeeName.substring(0, 20)}...';
                  }

                  double quantity = employees.grossSales ?? 0;

                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: Dimensions.height8),
                    child: MainSalesWidget(
                      itemName: employeeName,
                      quantity: quantity,
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
