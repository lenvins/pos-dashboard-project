import 'package:get/get.dart';
import 'package:pos_dashboard/data/repositories/item_repo.dart';
import 'package:pos_dashboard/presentation/controllers/login_controller.dart';

class DashboardController extends GetxController{
  bool isInitialized = false;
  final ItemRepository itemRepository;
  final LoginController loginController;

  DashboardController({
    required this.itemRepository, 
    required this.loginController
  });

  @override
  void onInit() async {
    super.onInit();
    try {
      await _initializedDependencies();
      isInitialized = true;
      update();
    } catch (e) {
      print('Dashboard initialization error at dashboard_controller.dart: $e');
      isInitialized = false;
      update();
    }
  }

  Future<void> _initializedDependencies() async {
    await itemRepository.getItemList();
  }
}