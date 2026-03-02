import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pos_dashboard/core/dependencies.dart' as dep;
import 'package:pos_dashboard/data/repositories/item_repo.dart';
import 'package:pos_dashboard/data/repositories/merchant_repo.dart';
import 'package:pos_dashboard/data/repositories/send_otp_repo.dart';
import 'package:pos_dashboard/data/repositories/top_dashboard_repo.dart';
import 'package:pos_dashboard/data/repositories/verify_otp_repo.dart';
import 'package:pos_dashboard/data/repositories/verify_pin_repo.dart';
import 'package:pos_dashboard/notification/notification_service.dart';
import 'package:pos_dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:pos_dashboard/presentation/controllers/item_controller.dart';
import 'package:pos_dashboard/presentation/controllers/login_controller.dart';
import 'package:pos_dashboard/presentation/controllers/merchant_controller.dart';
import 'package:pos_dashboard/presentation/controllers/theme_controller.dart';
import 'package:pos_dashboard/data/repositories/login_repo.dart';
import 'package:pos_dashboard/presentation/controllers/top_dashboard_controller.dart';
import 'package:pos_dashboard/presentation/screens/login/login_screen.dart';
import 'package:pos_dashboard/presentation/screens/login/otp_verification_screen.dart';
import 'package:pos_dashboard/presentation/screens/login/pin_verification_screen.dart';
import 'package:pos_dashboard/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:pos_dashboard/core/utils/app_constants.dart';
import 'package:pos_dashboard/core/api/api_client.dart';
import 'package:pos_dashboard/core/theme/app_theme.dart';
import 'package:pos_dashboard/presentation/controllers/otp_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  try {
    await dep.init();
    await NotificationService().init();
    final themeController = Get.put(ThemeController());
    await themeController.loadTheme();

    Get.put<ApiClient>(ApiClient(baseUrl: AppConstants.BASE_URL));
    Get.put<Dio>(Dio(BaseOptions(baseUrl: AppConstants.BASE_URL)));

    Get.put<LoginRepository>(LoginRepository(dio: Get.find()));
    Get.put<LoginController>(LoginController(loginRepository: Get.find()));

    Get.put<SendOtpRepo>(SendOtpRepo(apiClient: Get.find()));
    Get.put<VerifyOtpRepo>(VerifyOtpRepo(apiClient: Get.find(), loginController: Get.find()));
    Get.put<VerifyPinRepo>(VerifyPinRepo(apiClient: Get.find(), loginController: Get.find()));

    Get.lazyPut(() => OTPController(), fenix: true);
    
    Get.put<ItemRepository>(ItemRepository(apiClient: Get.find(), loginController: Get.find()));
    Get.put<ItemController>(ItemController(itemRepository: Get.find()));

    Get.put<TopDashboardRepo>(TopDashboardRepo(apiClient: Get.find(), loginController: Get.find()));
    Get.put<TopDashboardController>(TopDashboardController(topDashboardRepo: Get.find()));

    Get.put<MerchantRepository>(MerchantRepository(apiClient: Get.find(), loginController: Get.find()));
    Get.put<MerchantController>(MerchantController(merchantRepository: Get.find()),);

    runApp(const PosDashboardApp());
  } catch (e) {
    print('Initialization failed: $e');
    runApp(ErrorApp(errorMessage: e.toString()));
  }
}

class PosDashboardApp extends StatelessWidget {
  const PosDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: Get.find<LoginController>().getInitialRoute(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.lightTheme.primaryColor,
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          print('Error determining initial route: ${snapshot.error}');
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: LoginScreen(),
          );
        }

        final initialRoute = snapshot.data ?? '/';

        return GetBuilder<ThemeController>(
          builder: (themeController) => GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                themeController.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: initialRoute,
            getPages: [
              GetPage(
                name: "/",
                page: () => LoginScreen(),
                transition: Transition.fadeIn,
              ),
              GetPage(
                name: "/otp-verification",
                page: () => const OTPVerificationScreen(),
                transition: Transition.fadeIn,
              ),
              GetPage(
                name: "/pin-verification",
                page: () => PinVerificationScreen(),
                transition: Transition.fadeIn,
              ),
              GetPage(
                name: "/dashboard",
                page: () => const DashboardScreen(),
                binding: DashboardBinding(),
                transition: Transition.fadeIn,
              ),
            ],
          ),
        );
      },
    );
  }
}

class DashboardBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => DashboardController(
        itemRepository: Get.find(),
        loginController: Get.find(),
      ),
    );
     Get.lazyPut(() => TopDashboardController(topDashboardRepo: Get.find()));
     Get.lazyPut(() => MerchantController(merchantRepository: Get.find()));
  }
}

class ErrorApp extends StatelessWidget {
  final String errorMessage;

  const ErrorApp({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: Center(child: Text('Error: $errorMessage'))),
    );
  }
}
