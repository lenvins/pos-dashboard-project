import 'package:get/get.dart';
import 'package:pos_dashboard/core/api/api_client.dart';
import 'package:pos_dashboard/core/utils/app_constants.dart';
import 'package:pos_dashboard/presentation/controllers/login_controller.dart';

class SendOtpRepo extends GetxService {
  final ApiClient apiClient;
  final LoginController? loginController;

  SendOtpRepo({
    required this.apiClient,
    this.loginController
  });

  Future getSendOTP({String? phoneNumber, String? userId, String? accessToken}) async {
    final controller = loginController ?? Get.find<LoginController>();
    
    String phone = phoneNumber ?? controller.phoneNumber;
    String user = userId ?? controller.userId;
    String token = accessToken ?? controller.accessToken;
    
    Map<String, dynamic> body = {
      "MobileNo": phone,
      "UserId": user,
      "AppHash": "XMsemExH"
    };
    
    return apiClient.postData(
      AppConstants.SENDOTP,
      body,
      authToken: token.isNotEmpty ? token : null
    );
  }
}