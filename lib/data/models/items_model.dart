class ItemModel {

  late List<Items> _items;
  List<Items> get items=>_items;

  late List<Categories> _categories;
  List<Categories> get categories=>_categories;

  ItemModel({
    required items, 
    required categories
    }){
      _items = items;
      _categories = categories;
    }

  ItemModel.fromJson(Map<String, dynamic> json) {
    if (json['Items'] != null) {
      _items = <Items>[];
      json['Items'].forEach((v) {
        _items!.add(new Items.fromJson(v));
      });
    }
    if (json['Categories'] != null) {
      _categories = <Categories>[];
      json['Categories'].forEach((v) {
        _categories!.add(new Categories.fromJson(v));
      });
    }
  }
}

class Items {
  int? itemId;
  int? sKUId;
  int? categoryId;
  String? itemName;
  int? combiName;
  double? price;
  int? currentStock;
  String? imgUrl;
  int? storeId;

  Items({
    this.itemId,
    this.sKUId,
    this.categoryId,
    this.itemName,
    this.combiName,
    this.price,
    this.currentStock,
    this.imgUrl,
    this.storeId,
  });

  Items.fromJson(Map<String, dynamic> json) {
    itemId = json['ItemId'] is double ? json['ItemId'].toInt() : json['ItemId'];
    sKUId = json['SKUId'] is double ? json['SKUId'].toInt() : json['SKUId'];
    categoryId = json['CategoryId'] is double ? json['CategoryId'].toInt() : json['CategoryId'];
    itemName = json['ItemName'];
    combiName = json['CombiName'];
    price = json['Price'];
    currentStock = json['CurrentStock'] is double ? json['CurrentStock'].toInt() : json['CurrentStock'];
    imgUrl = json['ImgUrl'];
    storeId = json['StoreId'] is double ? json['StoreId'].toInt() : json['StoreId'];
  }
}

class Categories {
  int? id;
  String? categoryName;

  Categories({this.id, this.categoryName});

  Categories.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    categoryName = json['CategoryName'];
  }
}
