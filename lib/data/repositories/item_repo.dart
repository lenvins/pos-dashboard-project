import 'package:dio/src/response.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:pos_dashboard/core/api/api_client.dart';
import 'package:pos_dashboard/core/utils/app_constants.dart';
import 'package:pos_dashboard/presentation/controllers/login_controller.dart';

class ItemRepository extends GetxService {
  final ApiClient apiClient;
  final LoginController loginController;

  ItemRepository({
    required this.apiClient,
    required this.loginController
    });

  Future<Response> getItemList({
    int storeId = 0,
    int posId = 0,
    int recordsPerPage = 100,
    int offset = 0,
  }) async {
    
    String accessToken = loginController.accessToken;
    
    print("=== FETCHING ITEMS ===");
    print("Store ID: $storeId");
    print("POS ID: $posId");
    print("Records Per Page: $recordsPerPage");
    print("Offset: $offset");
    print("Merchant ID: ${loginController.merchantId}");

    Map<String, dynamic> body = {
      "StoreId": storeId > 0 ? storeId : 0,
      "POSId": posId > 0 ? posId : 0,
      "RecordsPerPage": recordsPerPage,
      "OffSet": offset
    };

    print("Request Body: $body");
    print("Endpoint: ${AppConstants.PRODUCT_URI}");

    try {
      final response = await apiClient.postData(
        AppConstants.PRODUCT_URI, 
        body,
        authToken: accessToken
      );

      print("✅ Items Response Status: ${response.statusCode}");
      print("✅ Items Response Data: ${response.data}");

      return response;
    } catch (e) {
      print("❌ Error fetching items: $e");
      rethrow;
    }
  }
}