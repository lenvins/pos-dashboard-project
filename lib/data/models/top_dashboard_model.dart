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

  // Always initialize to avoid late-init crashes and allow empty state.
  List<Top5Categories> _top5Categories = [];
  List<Top5Employees> _top5Employees = [];
  List<Top5Items> _top5Items = [];

  List<Top5Categories> get top5Categories => _top5Categories;
  List<Top5Employees> get top5Employees => _top5Employees;
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

  static dynamic _pick(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      if (json.containsKey(k)) return json[k];
      // also try case-insensitive match
      final match = json.keys.where((existing) => existing.toLowerCase() == k.toLowerCase());
      if (match.isNotEmpty) return json[match.first];

    }
    return null;
  }

  static double? _pickDouble(Map<String, dynamic> json, List<String> keys) {
    final v = _pick(json, keys);
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static int? _pickInt(Map<String, dynamic> json, List<String> keys) {
    final v = _pick(json, keys);
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static String? _pickString(Map<String, dynamic> json, List<String> keys) {
    final v = _pick(json, keys);
    if (v == null) return null;
    return v.toString();
  }

  TopDashboardModel.fromJson(Map<String, dynamic> json) {
    statusCode = _pickInt(json, ['status_code', 'StatusCode']);
    message = _pickString(json, ['message', 'Message']);

    barchartPerHour = _pickString(
      json,
      ['BarchartPerHour', 'barchartPerHour', 'barchart_per_hour', 'Barchartperhour'],
    );

    salesToday = _pickDouble(json, ['SalesToday', 'salesToday', 'sales_today']);
    grossSales = _pickDouble(json, ['GrossSales', 'grossSales', 'gross_sales']);
    receipts = _pickInt(json, ['Receipts', 'receipts']);

    refunds = _pickDouble(json, ['Refunds', 'refunds']);
    discounts = _pickDouble(json, ['Discounts', 'discounts']);
    costOfGoods = _pickDouble(json, ['CostOfGoods', 'costOfGoods', 'cost_of_goods']);
    grossProfit = _pickDouble(json, ['GrossProfit', 'grossProfit', 'gross_profit']);

    final catsRaw = _pick(json, ['Top5Categories', 'top5_categories']);
    if (catsRaw is List) {
      _top5Categories = catsRaw
          .whereType<Map<String, dynamic>>()
          .map((e) => Top5Categories.fromJson(e))
          .toList();
    }

    final empRaw = _pick(json, ['Top5Employees', 'top5_employees']);
    if (empRaw is List) {
      _top5Employees = empRaw
          .whereType<Map<String, dynamic>>()
          .map((e) => Top5Employees.fromJson(e))
          .toList();
    }

    final itemsRaw = _pick(json, ['Top5Items', 'top5_items']);
    if (itemsRaw is List) {
      _top5Items = itemsRaw
          .whereType<Map<String, dynamic>>()
          .map((e) => Top5Items.fromJson(e))
          .toList();
    }
  }
}

class Top5Categories {
  String? categoryName;
  double? grossSales;

  Top5Categories({this.categoryName, this.grossSales});

  Top5Categories.fromJson(Map<String, dynamic> json) {
    categoryName = TopDashboardModel._pickString(
      json,
      ['CategoryName', 'categoryName', 'category_name'],
    );
    grossSales = TopDashboardModel._pickDouble(
      json,
      ['GrossSales', 'grossSales', 'gross_sales'],
    );
  }
}

class Top5Employees {
  String? employeeName;
  double? grossSales;

  Top5Employees({this.employeeName, this.grossSales});

  Top5Employees.fromJson(Map<String, dynamic> json) {
    employeeName = TopDashboardModel._pickString(
      json,
      ['EmployeeName', 'employeeName', 'employee_name'],
    );
    grossSales = TopDashboardModel._pickDouble(
      json,
      ['GrossSales', 'grossSales', 'gross_sales'],
    );
  }
}

class Top5Items {
  String? itemName;
  double? grossSales;

  Top5Items({this.itemName, this.grossSales});

  Top5Items.fromJson(Map<String, dynamic> json) {
    itemName = TopDashboardModel._pickString(
      json,
      ['ItemName', 'itemName', 'item_name'],
    );
    grossSales = TopDashboardModel._pickDouble(
      json,
      ['GrossSales', 'grossSales', 'gross_sales'],
    );
  }
}

