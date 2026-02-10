import 'package:dio/src/response.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:pos_dashboard/core/api/api_client.dart';
import 'package:pos_dashboard/core/utils/app_constants.dart';
import 'package:pos_dashboard/presentation/controllers/login_controller.dart';

class TopDashboardRepo extends GetxService {
  final ApiClient apiClient;
  final LoginController loginController;

  TopDashboardRepo({
    required this.apiClient,
    required this.loginController
  });

  Future<Response> getTopList({
    required DateTime date,
    required List<int> storeIds,
  }) async {

    String accessToken = loginController.accessToken;

    Map<String, dynamic> body = {
      "Date": "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      "StoreIds": storeIds
    };

    return await apiClient.postData(
      AppConstants.TOP5_PRODUCT, 
      body,
      authToken: accessToken
      );
  }
}