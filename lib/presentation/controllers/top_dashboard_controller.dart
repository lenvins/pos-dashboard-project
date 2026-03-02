import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:pos_dashboard/data/models/top_dashboard_model.dart';
import 'package:pos_dashboard/data/repositories/top_dashboard_repo.dart';

class TopDashboardController extends GetxController {
  final TopDashboardRepo topDashboardRepo;

  TopDashboardController({required this.topDashboardRepo});

  TopDashboardModel? _topDashboardModel;
  TopDashboardModel? get topDashboardModel => _topDashboardModel;

  List<Top5Categories> _top5CategoriesList = [];
  List<Top5Categories> get top5CategoriesList => _top5CategoriesList;

  List<Top5Employees> _top5EmployeesList = [];
  List<Top5Employees> get top5EmployeesList => _top5EmployeesList;

  List<Top5Items> _top5ItemsList = [];
  List<Top5Items> get top5ItemsList => _top5ItemsList;

  String? _barchartPerHour;
  String? get barchartPerHour => _barchartPerHour;

  final List<double> _hourlySales = List.filled(24, 0.0);
  List<double> get hourlySales => _hourlySales;
  
  Future<void> getTopList({
    required DateTime date,
    required List<int> storeIds,
  }) async {
    try {
      dio.Response response = await topDashboardRepo.getTopList(
        date: date,
        storeIds: storeIds,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Got data. Source: top_dashboard_controller.dart");
        final model = TopDashboardModel.fromJson(response.data ?? {});

        if (_hasUsableApiData(model)) {
          _applyDashboardData(model);
          _logLoadedSummary(source: "api");
          update();
          return;
        }

        print("API returned empty sales summary data. Using temporary mock data.");
        _applyMockData(
          date: date,
          storeIds: storeIds,
          reason: "empty_api_data",
        );
        update();
        return;
      } else {
        print(
          "No data. Source: top_dashboard_controller.dart, status code: ${response.statusCode}",
        );
        _applyMockData(
          date: date,
          storeIds: storeIds,
          reason: "status_${response.statusCode}",
        );
        update();
        return;
      }
    } catch (e) {
      print("Error in getTopList: $e");
      _applyMockData(
        date: date,
        storeIds: storeIds,
        reason: "exception",
      );
      update();
      return;
    }
  }

  void _applyDashboardData(TopDashboardModel model) {
    _topDashboardModel = model;
    _top5CategoriesList = _safeTop5Categories(model);
    _top5EmployeesList = _safeTop5Employees(model);
    _top5ItemsList = _safeTop5Items(model);
    _barchartPerHour = model.barchartPerHour;
    _setHourlySalesFromChartData(_barchartPerHour);
  }

  bool _hasUsableApiData(TopDashboardModel model) {
    final hasSummary = (model.grossSales ?? 0) > 0 ||
        (model.salesToday ?? 0) > 0 ||
        (model.receipts ?? 0) > 0;
    final hasChart = (model.barchartPerHour ?? '').trim().isNotEmpty;
    final hasTopLists = _safeTop5Categories(model).isNotEmpty ||
        _safeTop5Employees(model).isNotEmpty ||
        _safeTop5Items(model).isNotEmpty;
    return hasSummary || hasChart || hasTopLists;
  }

  List<Top5Categories> _safeTop5Categories(TopDashboardModel model) {
    try {
      return List<Top5Categories>.from(model.top5Categories);
    } catch (_) {
      return <Top5Categories>[];
    }
  }

  List<Top5Employees> _safeTop5Employees(TopDashboardModel model) {
    try {
      return List<Top5Employees>.from(model.top5Employees);
    } catch (_) {
      return <Top5Employees>[];
    }
  }

  List<Top5Items> _safeTop5Items(TopDashboardModel model) {
    try {
      return List<Top5Items>.from(model.top5Items);
    } catch (_) {
      return <Top5Items>[];
    }
  }

  void _setHourlySalesFromChartData(String? barchartData) {
    for (int i = 0; i < _hourlySales.length; i++) {
      _hourlySales[i] = 0.0;
    }

    if (barchartData == null || barchartData.trim().isEmpty) {
      return;
    }

    try {
      final hourlyData = barchartData.split(',');
      for (int i = 0; i < hourlyData.length && i < 24; i++) {
        _hourlySales[i] = double.tryParse(hourlyData[i].trim()) ?? 0.0;
      }
    } catch (e) {
      print("Error parsing barchartPerHour data: $e");
    }
  }

  double _round2(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  String _formatDateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return "$year-$month-$day";
  }

  List<String> _rotateNames(List<String> names, int shift) {
    if (names.isEmpty) {
      return names;
    }

    final normalizedShift = shift % names.length;
    return <String>[
      ...names.sublist(normalizedShift),
      ...names.sublist(0, normalizedShift),
    ];
  }

  List<double> _buildTopValues({
    required double grossSales,
    required int seed,
    required double coverage,
    required int length,
  }) {
    if (length <= 0 || grossSales <= 0) {
      return List<double>.filled(length, 0.0);
    }

    final rawWeights = List<double>.generate(length, (index) {
      final baseRank = (length - index).toDouble();
      final seedBump = ((seed + (index * 5)) % 4) * 0.18;
      return baseRank + seedBump;
    });

    final totalWeight = rawWeights.fold<double>(0.0, (sum, w) => sum + w);
    if (totalWeight <= 0) {
      return List<double>.filled(length, 0.0);
    }

    final coveredSales = grossSales * coverage;
    return rawWeights
        .map((weight) => _round2((weight / totalWeight) * coveredSales))
        .toList();
  }

  TopDashboardModel _buildDateAwareMockModel({
    required DateTime date,
    required List<int> storeIds,
  }) {
    final selectedDate = DateTime(date.year, date.month, date.day);
    final daySeed =
        selectedDate.difference(DateTime(2024, 1, 1)).inDays.abs();
    final storeSeed =
        storeIds.isEmpty
            ? 1
            : storeIds.fold<int>(0, (sum, id) => sum + id.abs());

    final isWeekend =
        selectedDate.weekday == DateTime.saturday ||
        selectedDate.weekday == DateTime.sunday;

    final dateMultiplier = 0.82 + ((daySeed % 8) * 0.07);
    final storeMultiplier = 0.92 + ((storeSeed % 5) * 0.05);
    final weekendMultiplier = isWeekend ? 1.12 : 1.0;
    final totalMultiplier = dateMultiplier * storeMultiplier * weekendMultiplier;

    const baseHourlyPattern = <double>[
      32, 26, 21, 18, 16, 22, 35, 48, 62, 79, 95, 108,
      120, 129, 141, 152, 160, 171, 164, 148, 127, 98, 72, 51,
    ];

    final hourShift = daySeed % 3;
    final hourlySales = List<double>.generate(24, (hour) {
      final template = baseHourlyPattern[(hour + hourShift) % 24];
      final microVariance =
          0.95 + (((daySeed + storeSeed + (hour * 11)) % 9) * 0.015);
      return _round2(template * totalMultiplier * microVariance);
    });

    final grossSales = _round2(
      hourlySales.fold<double>(0.0, (sum, value) => sum + value),
    );

    final discountRate = 0.03 + ((daySeed % 3) * 0.004);
    final refundRate = 0.01 + ((storeSeed % 3) * 0.002);
    final cogsRate = 0.43 + ((daySeed % 4) * 0.01);

    final discounts = _round2(grossSales * discountRate);
    final refunds = _round2(grossSales * refundRate);
    final costOfGoods = _round2(grossSales * cogsRate);
    final salesToday = _round2(grossSales - discounts - refunds);
    final grossProfit = _round2(
      grossSales - costOfGoods - discounts - refunds,
    );

    var receipts = (grossSales / 85).round();
    if (receipts < 1) {
      receipts = 1;
    }

    final categoryNames = _rotateNames(<String>[
      "Beverages",
      "Meals",
      "Snacks",
      "Desserts",
      "Add-ons",
    ], daySeed + storeSeed);

    final employeeNames = _rotateNames(<String>[
      "Employee A",
      "Employee B",
      "Employee C",
      "Employee D",
      "Employee E",
    ], daySeed + (storeSeed * 2));

    final itemNames = _rotateNames(<String>[
      "Burger Combo",
      "Iced Coffee",
      "Chicken Rice",
      "Fries",
      "Milk Tea",
    ], daySeed + (storeSeed * 3));

    final categoryValues = _buildTopValues(
      grossSales: grossSales,
      seed: daySeed + storeSeed,
      coverage: 0.72,
      length: 5,
    );

    final employeeValues = _buildTopValues(
      grossSales: grossSales,
      seed: daySeed + (storeSeed * 2),
      coverage: 0.68,
      length: 5,
    );

    final itemValues = _buildTopValues(
      grossSales: grossSales,
      seed: daySeed + (storeSeed * 3),
      coverage: 0.64,
      length: 5,
    );

    final categories = List<Top5Categories>.generate(
      5,
      (index) => Top5Categories(
        categoryName: categoryNames[index],
        grossSales: categoryValues[index],
      ),
    );

    final employees = List<Top5Employees>.generate(
      5,
      (index) => Top5Employees(
        employeeName: employeeNames[index],
        grossSales: employeeValues[index],
      ),
    );

    final items = List<Top5Items>.generate(
      5,
      (index) => Top5Items(
        itemName: itemNames[index],
        grossSales: itemValues[index],
      ),
    );

    final chartString =
        hourlySales.map((value) => value.toStringAsFixed(2)).join(',');

    return TopDashboardModel(
      statusCode: 200,
      message: "mock_data_${_formatDateKey(selectedDate)}",
      barchartPerHour: chartString,
      salesToday: salesToday,
      grossSales: grossSales,
      receipts: receipts,
      refunds: refunds,
      discounts: discounts,
      costOfGoods: costOfGoods,
      grossProfit: grossProfit,
      top5Categories: categories,
      top5Employees: employees,
      top5Items: items,
    );
  }

  void _applyMockData({
    required DateTime date,
    required List<int> storeIds,
    required String reason,
  }) {
    _topDashboardModel = _buildDateAwareMockModel(
      date: date,
      storeIds: storeIds,
    );

    _top5CategoriesList = _safeTop5Categories(_topDashboardModel!);
    _top5EmployeesList = _safeTop5Employees(_topDashboardModel!);
    _top5ItemsList = _safeTop5Items(_topDashboardModel!);
    _barchartPerHour = _topDashboardModel!.barchartPerHour;
    _setHourlySalesFromChartData(_barchartPerHour);

    print(
      "Temporary mock sales data applied (reason: $reason, date: ${date.toIso8601String()}, stores: $storeIds)",
    );
    print(
      "Mock summary check - gross: ${_topDashboardModel!.grossSales}, salesToday: ${_topDashboardModel!.salesToday}, chartHours: ${_topDashboardModel!.barchartPerHour?.split(',').length ?? 0}",
    );
    _logLoadedSummary(source: "mock");
  }

  void _logLoadedSummary({required String source}) {
    print("Sales summary source: $source");
    print("Number of top 5 categories loaded: ${_top5CategoriesList.length}");
    print("Number of top 5 employees loaded: ${_top5EmployeesList.length}");
    print("Number of top 5 items loaded: ${_top5ItemsList.length}");
    print("Bar chart data loaded: ${_hourlySales.length} hours");

    if (_top5CategoriesList.isNotEmpty) {
      print("Sample top category: ${_top5CategoriesList.first}");
    }

    if (_top5EmployeesList.isNotEmpty) {
      print("Sample top employee: ${_top5EmployeesList.first}");
    }

    if (_top5ItemsList.isNotEmpty) {
      print("Sample top item: ${_top5ItemsList.first}");
    }
  }
}
