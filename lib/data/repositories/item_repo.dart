import 'package:dio/src/response.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:pos_dashboard/core/api/api_client.dart';
import 'package:pos_dashboard/core/utils/app_constants.dart';
import 'package:pos_dashboard/presentation/controllers/login_controller.dart';

class ItemRepository extends GetxService {
  final ApiClient apiClient;
  final LoginController loginController;
  //late Map<String, dynamic> body;

  ItemRepository({
    required this.apiClient,
    required this.loginController
    });

  //CHANGE WITH MERCHANTCONTROLLER
  Map<String, dynamic> body = {
    "StoreId": 1,
    "POSId": 2,
    "RecordsPerPage": 3,
    "OffSet": 4
  };

  Future<Response> getItemList() async {
    
    //TOKEN FROM THE LOGIN
    String accessToken = loginController.accessToken;

    return await apiClient.postData(
      AppConstants.PRODUCT_URI, 
      body,
      authToken: accessToken
    );
  }
}