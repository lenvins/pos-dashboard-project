import 'package:dio/src/response.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:pos_dashboard/core/api/api_client.dart';
import 'package:pos_dashboard/core/utils/app_constants.dart';
import 'package:pos_dashboard/presentation/controllers/login_controller.dart';

class MerchantRepository extends GetxService {
  final ApiClient apiClient;
  final LoginController loginController;
  late Map<String, dynamic> body;

  MerchantRepository({
    required this.apiClient,
    required this.loginController,
  }) {
    body = {
      "MerchantId": loginController.merchantId
    };
  }

  Future<Response> getMerchantList() async {

    String accessToken = loginController.accessToken;

    return await apiClient.postData(
      AppConstants.MERCHANTSTORE,
      body,
      authToken: accessToken
    );
  }
}