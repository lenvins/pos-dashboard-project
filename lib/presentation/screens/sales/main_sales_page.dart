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
import 'package:pos_dashboard/presentation/widgets/date_selector.dart' show PeriodSelector, DatePeriod;

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

  late DateTimeRange selectedRange;
  late DatePeriod selectedPeriod;
  int? selectedStoreId;
  String? selectedStoreName;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedRange = DateTimeRange(start: now, end: now);
    selectedPeriod = DatePeriod.today;
    _loadData();
  }

  void _loadData() async {
    print("📍 [MainSalesPage] _loadData() called");
    
    await merchantController.getMerchantList();

    print("📍 [MainSalesPage] Store list count: ${merchantController.storeList.length}");

    if (merchantController.storeList.isNotEmpty) {
      print("✅ [MainSalesPage] Setting selected store to: ${merchantController.storeList[0].storeName}");
      setState(() {
        selectedStoreId = merchantController.storeList[0].storeId;
        selectedStoreName = merchantController.storeList[0].storeName;
      });
      _loadTopDashboardData();
    } else {
      print("❌ [MainSalesPage] No stores available! Showing 'No Stores Available' message");
    }
  }

  void _loadTopDashboardData() {
    if (selectedStoreId != null) {
      print("📍 [MainSalesPage] Loading top dashboard data...");
      topDashboardController.getTopList(
        date: selectedRange.start,
        storeIds: [selectedStoreId!],
      );
    }
  }

  Future<void> _loadTopDashboardDataAsync() async {
    if (selectedStoreId != null) {
      await topDashboardController.getTopList(
        date: selectedRange.start,
        storeIds: [selectedStoreId!],
      );
    }
  }

  Future<void> _onRefresh() async {
    print("🔄 [MainSalesPage] Pull-to-refresh triggered");
    
    // Simply reload data directly like SalesDetailsPage does
    _loadTopDashboardData();
    
    // Give a small delay to allow UI to respond
    await Future.delayed(const Duration(milliseconds: 500));
    
    print("✅ [MainSalesPage] Pull-to-refresh completed");
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
    return RefreshIndicator(
      onRefresh: _onRefresh,
      displacement: 40,
      strokeWidth: 2.5,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      color: const Color(0xFF00308F),
      child: Scrollbar(
        controller: _salesScrollController,
        thumbVisibility: true,
        interactive: true,
        child: SingleChildScrollView(
          controller: _salesScrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(Dimensions.font18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: PeriodSelector(
                      initialRange: selectedRange,
                      initialPeriod: selectedPeriod,
                      onRangeChanged: (newRange, newPeriod) {
                        setState(() {
                          selectedRange = newRange;
                          selectedPeriod = newPeriod;
                        });
                        _loadTopDashboardData();
                      },
                    ),
                  ),
                  //space for additional information
                ],
              ),
              SizedBox(height: Dimensions.height10),
              // Offline mode warning banner
              GetBuilder<TopDashboardController>(
                builder: (controller) {
                  if (controller.isOfflineMode && controller.lastError != null) {
                    return Container(
                      margin: EdgeInsets.only(bottom: Dimensions.height15),
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width15,
                        vertical: Dimensions.height10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(Dimensions.radius15),
                        border: Border.all(color: Colors.orange, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.orange, size: Dimensions.iconSize20),
                          SizedBox(width: Dimensions.width10),
                          Expanded(
                            child: Text(
                              controller.lastError ?? 'Offline mode',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontSize: Dimensions.font14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
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
      ),
    );
  }
}
