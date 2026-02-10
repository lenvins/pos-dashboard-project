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

  List<double> _hourlySales = List.filled(24, 0.0);
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
        _topDashboardModel = TopDashboardModel.fromJson(response.data);

        _top5CategoriesList = _topDashboardModel!.top5Categories;
        _top5EmployeesList = _topDashboardModel!.top5Employees;
        _top5ItemsList = _topDashboardModel!.top5Items;
        _barchartPerHour = _topDashboardModel!.barchartPerHour;

        if (_barchartPerHour != null) {
          try {
            List<String> hourlyData = _barchartPerHour!.split(',');
            for (int i = 0; i < hourlyData.length && i < 24; i++) {
              _hourlySales[i] = double.tryParse(hourlyData[i]) ?? 0.0;
            }
          } catch (e) {
            print("Error parsing barchartPerHour data: $e");
          }
        }

        update();

        print(
          "Number of top 5 categories loaded: ${_top5CategoriesList.length}",
        );
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
      } else {
        print(
          "No data. Source: top_dashboard_controller.dart, status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      print("Error in getTopList: $e");
    }
  }
  
}
