import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:pos_dashboard/data/models/merchant_model.dart';
import 'package:pos_dashboard/data/repositories/merchant_repo.dart';

class MerchantController extends GetxController {
  final MerchantRepository merchantRepository;
  final RxBool isLoading = false.obs;

  MerchantController({
    required this.merchantRepository
  });

  List<Stores> _storeList = [];
  List<Stores> get storeList => _storeList;

  Future<void> getMerchantList() async {
    isLoading.value = true;
    try {
      print("📦 [MerchantController] Starting getMerchantList()");
      
      dio.Response response = await merchantRepository.getMerchantList();

      print("📤 [MerchantController] Response Status: ${response.statusCode}");
      print("📤 [MerchantController] Response Data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ [MerchantController] Got data. Parsing merchant model...");
        
        MerchantModel merchantModel = MerchantModel.fromJson(response.data);
        _storeList = merchantModel.stores ?? [];
        
        print("✅ [MerchantController] Number of stores loaded: ${_storeList.length}");

        if (_storeList.isNotEmpty) {
          print("✅ [MerchantController] Stores:");
          for (int i = 0; i < _storeList.length; i++) {
            print("   Store $i: ${_storeList[i].storeName} (ID: ${_storeList[i].storeId})");
          }
        } else {
          print("⚠️ [MerchantController] No stores in response");
        }
        
        update();
      } else {
        print("❌ [MerchantController] Failed to get data. Status: ${response.statusCode}");
        print("Response: ${response.data}");
      }
    } catch (e) {
      print("❌ [MerchantController] Error fetching store list: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
