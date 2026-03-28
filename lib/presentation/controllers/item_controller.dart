import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:pos_dashboard/data/models/items_model.dart';
import 'package:pos_dashboard/data/repositories/item_repo.dart';

class ItemController extends GetxController {
  final ItemRepository itemRepository;

  ItemController({required this.itemRepository});

  List<Items> _itemList = [];
  List<Items> get itemList => _itemList;

  List<Categories> _categoryList = [];
  List<Categories> get categoryList => _categoryList;

  Future<void> getItemList({
    int storeId = 0,
    int posId = 0,
    int recordsPerPage = 100,
    int offset = 0,
  }) async {
    print("📦 [ItemController] Starting getItemList()");
    print("   StoreId: $storeId, POSId: $posId, Records: $recordsPerPage, Offset: $offset");
    
    try {
      dio.Response response = await itemRepository.getItemList(
        storeId: storeId,
        posId: posId,
        recordsPerPage: recordsPerPage,
        offset: offset,
      );

      print("📦 [ItemController] Response Status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ [ItemController] Got data");
        ItemModel itemModel = ItemModel.fromJson(response.data);
        _itemList = itemModel.items ?? [];
        _categoryList = itemModel.categories ?? [];
        update();

        print("✅ [ItemController] Number of items loaded: ${_itemList.length}");
        print("✅ [ItemController] Number of categories loaded: ${_categoryList.length}");

        if (_itemList.isNotEmpty) {
          print("   Sample item: ${_itemList.first.itemName}");
        }

        if (_categoryList.isNotEmpty) {
          print("   Sample category: ${_categoryList.first}");
        }
      } else {
        print("❌ [ItemController] Failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ [ItemController] Error fetching item list: $e");
    }
  }

  List<Items> getItemsByCategory(int categoryId) {
    return _itemList.where((item) => item.categoryId == categoryId).toList();
  }
}