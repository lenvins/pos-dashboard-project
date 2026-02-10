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
      dio.Response response = await merchantRepository.getMerchantList();

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Got data. Source: merchant_controller.dart");
        MerchantModel merchantModel = MerchantModel.fromJson(response.data);
        _storeList = merchantModel.stores;
        update();

        print("Number of stores loaded: ${_storeList.length}");

        if (_storeList.isNotEmpty) {
          print("Sample store: ${_storeList.first}");
        }
      } else {
        print("No data. Source: merchant_controller.dart, status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching store list: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
