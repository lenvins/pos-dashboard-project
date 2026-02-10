import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pos_dashboard/core/api/api_client.dart';
import 'package:pos_dashboard/core/utils/app_constants.dart';
import 'package:pos_dashboard/data/repositories/item_repo.dart';
import 'package:pos_dashboard/data/repositories/login_repo.dart';
import 'package:pos_dashboard/data/repositories/send_otp_repo.dart';
import 'package:pos_dashboard/presentation/controllers/item_controller.dart';
import 'package:pos_dashboard/presentation/controllers/login_controller.dart';

Future<void> init() async {
  Get.lazyPut(() => Dio(BaseOptions(baseUrl: AppConstants.BASE_URL)));

  Get.lazyPut(() => ItemRepository(
    apiClient: Get.find(),
    loginController: Get.find()
    ));
  Get.lazyPut(() => LoginRepository(dio: Get.find()));

  Get.lazyPut(() => ItemController(itemRepository: Get.find()));
  Get.lazyPut(() => LoginController(loginRepository: Get.find()));
  Get.lazyPut(() => SendOtpRepo(apiClient: Get.find()));

  Get.put<ApiClient>(ApiClient(baseUrl: AppConstants.BASE_URL));
}