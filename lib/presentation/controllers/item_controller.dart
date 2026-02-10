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

  Future<void> getItemList() async {
    try {
      dio.Response response = await itemRepository.getItemList();

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Got data. Source: item_controller.dart");
        ItemModel itemModel = ItemModel.fromJson(response.data);
        _itemList = itemModel.items;
        _categoryList = itemModel.categories;
        update();

        print("Number of items loaded: ${_itemList.length}");
        print("Number of categories loaded: ${_categoryList.length}");

        if (_itemList.isNotEmpty) {
          print("Sample item: ${_itemList.first}");
        }

        if (_categoryList.isNotEmpty) {
          print("Sample category: ${_categoryList.first}");
        }
      } else {
        print("No data. Source: item_controller.dart, status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching item list: $e");
    }
  }

  List<Items> getItemsByCategory(int categoryId) {
    return _itemList.where((item) => item.categoryId == categoryId).toList();
  }
}