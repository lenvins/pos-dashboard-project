import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StoreController extends GetxController {
  final _storage = GetStorage();
  final _currentStore = ''.obs;
  final _stores = <String>[].obs;

  String get currentStore => _currentStore.value;
  List<String> get stores => _stores;

  @override
  void onInit() {
    super.onInit();
    loadStores();
    loadCurrentStore();
  }

  void loadStores() {
    // TODO: Replace with actual API call to get stores
    _stores.value = ['All Stores', 'Store 1', 'Store 2', 'Store 3'];
  }

  void loadCurrentStore() {
    _currentStore.value = _storage.read('currentStore') ?? 'All Stores';
  }

  void changeStore(String store) {
    _currentStore.value = store;
    _storage.write('currentStore', store);
    // TODO: Trigger data refresh for the selected store
    update();
  }
}
