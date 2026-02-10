class TopDashboardModel {
  int? statusCode;
  String? message;
  String? barchartPerHour;
  double? salesToday;
  double? grossSales;
  int? receipts;
  double? refunds;
  double? discounts;
  double? costOfGoods;
  double? grossProfit;

  late List<Top5Categories> _top5Categories;
  List<Top5Categories> get top5Categories => _top5Categories;

  late List<Top5Employees> _top5Employees;
  List<Top5Employees> get top5Employees => _top5Employees;

  late List<Top5Items> _top5Items;
  List<Top5Items> get top5Items => _top5Items;

  TopDashboardModel({
    this.statusCode,
    this.message,
    this.barchartPerHour,
    this.salesToday,
    this.grossSales,
    this.receipts,
    this.refunds,
    this.discounts,
    this.costOfGoods,
    this.grossProfit,
    required top5Categories,
    required top5Employees,
    required top5Items,
  }) {
    _top5Categories = top5Categories;
    _top5Employees = top5Employees;
    _top5Items = top5Items;
  }

  TopDashboardModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'];
    message = json['message'];
    barchartPerHour = json['BarchartPerHour'];
    salesToday = json['SalesToday']?.toDouble();
    grossSales = json['GrossSales']?.toDouble();
    receipts = json['Receipts'];
    refunds = json['Refunds']?.toDouble();
    discounts = json['Discounts']?.toDouble();
    costOfGoods = json['CostOfGoods']?.toDouble();
    grossProfit = json['GrossProfit']?.toDouble();
    if (json['Top5Categories'] != null) {
      _top5Categories = <Top5Categories>[];
      json['Top5Categories'].forEach((v) {
        _top5Categories!.add(new Top5Categories.fromJson(v));
      });
    }
    if (json['Top5Employees'] != null) {
      _top5Employees = <Top5Employees>[];
      json['Top5Employees'].forEach((v) {
        _top5Employees!.add(new Top5Employees.fromJson(v));
      });
    }
    if (json['Top5Items'] != null) {
      _top5Items = <Top5Items>[];
      json['Top5Items'].forEach((v) {
        _top5Items!.add(new Top5Items.fromJson(v));
      });
    }
  }
}

class Top5Categories {
  String? categoryName;
  double? grossSales;

  Top5Categories({this.categoryName, this.grossSales});

  Top5Categories.fromJson(Map<String, dynamic> json) {
    categoryName = json['CategoryName'];
    grossSales = json['GrossSales']?.toDouble();
  }
}

class Top5Employees {
  String? employeeName;
  double? grossSales;

  Top5Employees({this.employeeName, this.grossSales});

  Top5Employees.fromJson(Map<String, dynamic> json) {
    employeeName = json['EmployeeName'];
    grossSales = json['GrossSales']?.toDouble();
  }
}

class Top5Items {
  String? itemName;
  double? grossSales;

  Top5Items({this.itemName, this.grossSales});

  Top5Items.fromJson(Map<String, dynamic> json) {
    itemName = json['ItemName'];
    grossSales = json['GrossSales']?.toDouble();
  }
}
