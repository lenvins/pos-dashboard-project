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
    if (json['Stores'] != null) {
      _stores = <Stores>[];
      json['Stores'].forEach((v) {
        _stores!.add(new Stores.fromJson(v));
      });
    }
  }
}

class Stores {
  int? storeId;
  String? storeName;

  Stores({this.storeId, this.storeName});

  Stores.fromJson(Map<String, dynamic> json) {
    storeId = json['StoreId'];
    storeName = json['StoreName'];
  }
}
