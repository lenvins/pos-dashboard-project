import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pos_dashboard/core/api/api_client.dart';
import 'package:pos_dashboard/core/utils/app_constants.dart';
import 'package:pos_dashboard/data/repositories/item_repo.dart';
import 'package:pos_dashboard/data/repositories/login_repo.dart';
import 'package:pos_dashboard/data/repositories/send_otp_repo.dart';
import 'package:pos_dashboard/data/repositories/verify_otp_repo.dart';
import 'package:pos_dashboard/data/repositories/verify_pin_repo.dart';
import 'package:pos_dashboard/data/repositories/top_dashboard_repo.dart';
import 'package:pos_dashboard/data/repositories/merchant_repo.dart';
import 'package:pos_dashboard/presentation/controllers/item_controller.dart';
import 'package:pos_dashboard/presentation/controllers/login_controller.dart';
import 'package:pos_dashboard/presentation/controllers/top_dashboard_controller.dart';
import 'package:pos_dashboard/presentation/controllers/merchant_controller.dart';
import 'package:pos_dashboard/data/repositories/change_password_repo.dart';
import 'package:pos_dashboard/presentation/controllers/change_password_controller.dart';

Future<void> init() async {
  Get.lazyPut<ApiClient>(() => ApiClient(baseUrl: AppConstants.BASE_URL));
  Get.lazyPut<Dio>(() => Dio(BaseOptions(baseUrl: AppConstants.BASE_URL)));
  
  Get.lazyPut(() => LoginRepository(dio: Get.find<Dio>()));
  Get.lazyPut(() => LoginController(loginRepository: Get.find()), fenix: true);
  Get.lazyPut(() => ItemRepository(apiClient: Get.find(), loginController: Get.find()));
  Get.lazyPut(() => ItemController(itemRepository: Get.find()));
  Get.lazyPut(() => SendOtpRepo(apiClient: Get.find()));
  Get.lazyPut(() => VerifyOtpRepo(apiClient: Get.find(), loginController: Get.find()));
  Get.lazyPut(() => VerifyPinRepo(apiClient: Get.find(), loginController: Get.find()));
  Get.lazyPut(() => TopDashboardRepo(apiClient: Get.find(), loginController: Get.find()));
  Get.lazyPut(() => MerchantRepository(apiClient: Get.find(), loginController: Get.find()));
  Get.lazyPut(() => MerchantController(merchantRepository: Get.find()));
  Get.lazyPut(() => TopDashboardController(topDashboardRepo: Get.find()));

  // Always available change password deps (independent of login state)
  Get.put<ChangePasswordRepo>(ChangePasswordRepo(apiClient: Get.find()));
  Get.put<ChangePasswordController>(ChangePasswordController(repo: Get.find()), permanent: true);
  // Controllers lazy loaded

}
