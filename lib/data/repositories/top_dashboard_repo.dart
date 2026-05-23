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

    final formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    // API is case-sensitive in some backends; send both variants defensively.
    // (Backend should ignore unknown keys.)
    Map<String, dynamic> body = {
      "Date": formattedDate,
      "date": formattedDate,
      "StoreIds": storeIds,
      "storeIds": storeIds,
    };

    return await apiClient.postData(
      AppConstants.TOP5_PRODUCT,
      body,
      authToken: accessToken,
    );
  }
}

