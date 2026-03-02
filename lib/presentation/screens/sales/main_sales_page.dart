import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_dashboard/core/utils/dimensions.dart';
import 'package:pos_dashboard/data/models/merchant_model.dart';
import 'package:pos_dashboard/presentation/controllers/merchant_controller.dart';
import 'package:pos_dashboard/presentation/controllers/top_dashboard_controller.dart';
import 'package:pos_dashboard/presentation/screens/categories/categories_section.dart';
import 'package:pos_dashboard/presentation/screens/employees/employees_section.dart';
import 'package:pos_dashboard/presentation/screens/sales/charts/chart_section.dart';
import 'package:pos_dashboard/presentation/screens/items/item_section.dart';
import 'package:pos_dashboard/presentation/widgets/date_selector.dart';

class MainSalesPage extends StatefulWidget {
  const MainSalesPage({super.key});

  @override
  _MainSalesPage createState() => _MainSalesPage();
}

class _MainSalesPage extends State<MainSalesPage> {
  final MerchantController merchantController = Get.find<MerchantController>();
  final TopDashboardController topDashboardController =
      Get.find<TopDashboardController>();
  final ScrollController _salesScrollController = ScrollController();

  DateTime selectedDate = DateTime.now();
  int? selectedStoreId;
  String? selectedStoreName;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await merchantController.getMerchantList();

    if (merchantController.storeList.isNotEmpty) {
      setState(() {
        selectedStoreId = merchantController.storeList[0].storeId;
        selectedStoreName = merchantController.storeList[0].storeName;
      });
      _loadTopDashboardData();
    }
  }

  void _loadTopDashboardData() {
    if (selectedStoreId != null) {
      topDashboardController.getTopList(
        date: selectedDate,
        storeIds: [selectedStoreId!],
      );
    }
  }

  @override
  void dispose() {
    _salesScrollController.dispose();
    super.dispose();
  }

  List<Stores> getStores() {
    if (merchantController.storeList.isEmpty) {
      return [];
    }
    return merchantController.storeList;
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _salesScrollController,
      thumbVisibility: true,
      interactive: true,
      child: SingleChildScrollView(
        controller: _salesScrollController,
        padding: EdgeInsets.all(Dimensions.font18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: DateSelector(
                    selectedDate: selectedDate,
                    onDateChanged: (newDate) {
                      setState(() {
                        selectedDate = newDate;
                      });
                      _loadTopDashboardData();
                    },
                  ),
                ),
                //space for additional information
              ],
            ),
            SizedBox(height: Dimensions.height10),
            SizedBox(
              height: Dimensions.height40,
              width: double.infinity,
              child: Obx(() {
                if (merchantController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (merchantController.storeList.isEmpty) {
                  return const Center(child: Text('No Stores Available'));
                }
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: merchantController.storeList.length,
                  separatorBuilder:
                      (context, index) => SizedBox(width: Dimensions.width10),
                  itemBuilder: (context, index) {
                    final store = merchantController.storeList[index];
                    return ChoiceChip(
                      label: Text(store.storeName ?? 'Unknown Store'),
                      selected: selectedStoreId == store.storeId,
                      onSelected: (isSelected) {
                        if (isSelected) {
                          setState(() {
                            selectedStoreId = store.storeId;
                            selectedStoreName = store.storeName;
                            _loadTopDashboardData();
                          });
                        }
                      },
                    );
                  },
                );
              }),
            ),
            SizedBox(height: Dimensions.height20),
            ChartSection(),
            SizedBox(height: Dimensions.height20),
            ItemsSection(),
            SizedBox(height: Dimensions.height20),
            CategoriesSection(),
            SizedBox(height: Dimensions.height20),
            EmployeesSection(),
          ],
        ),
      ),
    );
  }
}
