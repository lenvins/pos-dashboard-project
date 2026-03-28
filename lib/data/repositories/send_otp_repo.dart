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
    
    print("=== SENDING OTP ===");
    print("Phone Number: $phone");
    print("User ID: $user");
    print("Access Token: $token");
    
    Map<String, dynamic> body = {
      "MobileNo": phone,
      "UserId": user,
      "AppHash": "XMsemExH"
    };
    
    print("Request Body: $body");
    print("Endpoint: ${AppConstants.SENDOTP}");
    
    try {
      final response = await apiClient.postData(
        AppConstants.SENDOTP,
        body,
        authToken: token.isNotEmpty ? token : null
      );
      
      print("OTP Send Response Status: ${response.statusCode}");
      print("OTP Send Response Data: ${response.data}");
      
      return response;
    } catch (e) {
      print("Error sending OTP: $e");
      rethrow;
    }
  }
}