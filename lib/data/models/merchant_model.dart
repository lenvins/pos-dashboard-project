class MerchantModel {
  int? statusCode;
  String? message;

  late List<Stores> _stores;
  List<Stores> get stores => _stores;

  MerchantModel({
    this.statusCode, 
    this.message, 
    required stores
  }){
    _stores = stores;
  }

  MerchantModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'];
    message = json['message'];
    
    print("🔍 [MerchantModel] Parsing from JSON");
    print("🔍 [MerchantModel] Status Code: $statusCode");
    print("🔍 [MerchantModel] Message: $message");
    print("🔍 [MerchantModel] Keys in response: ${json.keys.toList()}");
    
    _stores = <Stores>[];
    
    if (json['Stores'] != null) {
      print("✅ [MerchantModel] 'Stores' key found");
      json['Stores'].forEach((v) {
        _stores.add(Stores.fromJson(v));
      });
    } else if (json['stores'] != null) {
      print("✅ [MerchantModel] 'stores' (lowercase) key found");
      json['stores'].forEach((v) {
        _stores.add(Stores.fromJson(v));
      });
    } else if (json['data'] != null && json['data']['Stores'] != null) {
      print("✅ [MerchantModel] 'data.Stores' nested key found");
      json['data']['Stores'].forEach((v) {
        _stores.add(Stores.fromJson(v));
      });
    } else {
      print("⚠️ [MerchantModel] No 'Stores' key found in response");
    }
    
    print("🔍 [MerchantModel] Total stores parsed: ${_stores.length}");
  }
}

class Stores {
  int? storeId;
  String? storeName;

  Stores({this.storeId, this.storeName});

  Stores.fromJson(Map<String, dynamic> json) {
    storeId = json['StoreId'] ?? json['storeId'];
    storeName = json['StoreName'] ?? json['storeName'] ?? 'Unknown Store';
    print("   📍 Store: $storeName (ID: $storeId)");
  }
}
