import 'package:dio/src/response.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:pos_dashboard/core/api/api_client.dart';
import 'package:pos_dashboard/core/utils/app_constants.dart';
import 'package:pos_dashboard/presentation/controllers/login_controller.dart';

class VerifyOtpRepo extends GetxService {
  final ApiClient apiClient;
  final LoginController loginController;

  VerifyOtpRepo({
    required this.apiClient,
    required this.loginController,
  });

  Future<Response> getVerifyOTP(String otp) async {

    String accessToken = loginController.accessToken;
    String phoneNumber = loginController.phoneNumber;
    String userId = loginController.userId;

    print("=== VERIFYING OTP ===");
    print("OTP Code: $otp");
    print("Phone Number: $phoneNumber");
    print("User ID: $userId");
    print("Access Token: $accessToken");

    // Try primary endpoint first: shop/verifyotplogin
    print("\n📤 Attempt 1: Using ${AppConstants.VERIFYOTP}");
    
    Map<String, dynamic> body1 = {
      "OTP": otp,
      "MobileNo": phoneNumber,
      "UserId": userId,
      "AppHash": "XMsemExH",
    };

    print("Request Body: $body1");

    try {
      final response = await apiClient.postData(
        AppConstants.VERIFYOTP, 
        body1,
        authToken: accessToken,
      );
      
      print("Response Status: ${response.statusCode}");
      print("Response Data: ${response.data}");
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Attempt 1 succeeded!");
        return response;
      }
      
      // If primary endpoint fails, try fallback endpoint
      print("\n⚠️ Attempt 1 failed, trying fallback endpoint: ${AppConstants.VERIFYOTP_FALLBACK}");
      
      Map<String, dynamic> body2 = {
        "OTP": otp,
        "MobileNo": phoneNumber,
        "UserId": userId,
        "AppHash": "XMsemExH",
      };
      
      print("Request Body: $body2");
      
      final response2 = await apiClient.postData(
        AppConstants.VERIFYOTP_FALLBACK,
        body2,
        authToken: accessToken,
      );
      
      print("Response Status (Fallback): ${response2.statusCode}");
      print("Response Data (Fallback): ${response2.data}");
      
      return response2;
      
    } catch (e) {
      print("Error verifying OTP: $e");
      rethrow;
    }
  }
}