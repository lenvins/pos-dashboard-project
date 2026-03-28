# Data Refresh and Caching Analysis Report

## Executive Summary
Found **critical issues** preventing proper data refresh, especially with ItemController. The main problems are:
1. **ItemRepository** uses hardcoded request parameters that never change
2. ItemController data is not refreshed during pull-to-refresh in MainSalesPage
3. Data is stored correctly in controllers, but repository methods don't support dynamic parameters

---

## 1. TopDashboardController - getTopList() ✅ DATA REFRESHES

**File**: [lib/presentation/controllers/top_dashboard_controller.dart](lib/presentation/controllers/top_dashboard_controller.dart#L28-L75)

### Data Storage (Lines 7-24)
```dart
TopDashboardModel? _topDashboardModel;           // Stores single model
List<Top5Categories> _top5CategoriesList = [];   // Stores categories
List<Top5Employees> _top5EmployeesList = [];     // Stores employees
List<Top5Items> _top5ItemsList = [];             // Stores items
String? _barchartPerHour;                        // Stores chart data
final List<double> _hourlySales = List.filled(24, 0.0);  // Stores hourly sales
```

### getTopList() Method (Lines 28-75)
```dart
Future<void> getTopList({
  required DateTime date,
  required List<int> storeIds,
}) async {
  try {
    dio.Response response = await topDashboardRepo.getTopList(
      date: date,
      storeIds: storeIds,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final model = TopDashboardModel.fromJson(response.data ?? {});

      if (_hasUsableApiData(model)) {
        _applyDashboardData(model);  // Updates all lists
        update();                     // Notifies listeners
        return;
      }
      // Falls back to mock data if API returns empty
      _applyMockData(date: date, storeIds: storeIds, reason: "empty_api_data");
      update();
    }
  } catch (e) {
    print("Error in getTopList: $e");
    _applyMockData(date: date, storeIds: storeIds, reason: "exception");
    update();
  }
}
```

### _applyDashboardData() Method (Lines 77-84)
```dart
void _applyDashboardData(TopDashboardModel model) {
  _topDashboardModel = model;
  _top5CategoriesList = _safeTop5Categories(model);      // Clears & updates
  _top5EmployeesList = _safeTop5Employees(model);        // Clears & updates
  _top5ItemsList = _safeTop5Items(model);                // Clears & updates
  _barchartPerHour = model.barchartPerHour;
  _setHourlySalesFromChartData(_barchartPerHour);
}
```

**Status**: ✅ **WORKS CORRECTLY**
- Each call creates a fresh request with new date and storeIds
- Data is properly replaced (not appended)
- Listeners notified with `update()`
- Fallback to mock data if API fails

---

## 2. ItemController - getItemList() ⚠️ DATA REFRESHES BUT REPO HAS ISSUES

**File**: [lib/presentation/controllers/item_controller.dart](lib/presentation/controllers/item_controller.dart#L18-L49)

### Data Storage (Lines 8-16)
```dart
List<Items> _itemList = [];           // Stores all items
List<Categories> _categoryList = [];  // Stores all categories
```

### getItemList() Method (Lines 18-49)
```dart
Future<void> getItemList() async {
  try {
    dio.Response response = await itemRepository.getItemList();

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Got data. Source: item_controller.dart");
      ItemModel itemModel = ItemModel.fromJson(response.data);
      _itemList = itemModel.items;              // Replaces old data
      _categoryList = itemModel.categories;     // Replaces old data
      update();                                 // Notifies listeners

      print("Number of items loaded: ${_itemList.length}");
      print("Number of categories loaded: ${_categoryList.length}");
    }
  } catch (e) {
    print("Error fetching item list: $e");
  }
}
```

**Status**: ⚠️ **CONTROLLER WORKS BUT REPOSITORY HAS CRITICAL BUG**

---

## 3. ItemRepository.getItemList() 🔴 CRITICAL BUG - HARDCODED PARAMETERS

**File**: [lib/data/repositories/item_repo.dart](lib/data/repositories/item_repo.dart)

### Class Definition (Lines 6-28)
```dart
class ItemRepository extends GetxService {
  final ApiClient apiClient;
  final LoginController loginController;

  ItemRepository({
    required this.apiClient,
    required this.loginController
  });

  // ❌ CRITICAL: Static/Hardcoded body initialized only once
  Map<String, dynamic> body = {
    "StoreId": 1,        // Always 1!
    "POSId": 2,          // Always 2!
    "RecordsPerPage": 3, // Always 3!
    "OffSet": 4          // Always 4!
  };

  Future<Response> getItemList() async {
    String accessToken = loginController.accessToken;
    return await apiClient.postData(
      AppConstants.PRODUCT_URI, 
      body,  // ❌ Same body every time - NO FRESH PARAMETERS
      authToken: accessToken
    );
  }
}
```

**Status**: 🔴 **CRITICAL BUG**

### Problems:
1. **Hardcoded Parameters**: The `body` map is initialized once at class instantiation
2. **No Dynamic Store Selection**: Always requests `StoreId: 1` regardless of selected store
3. **No Pagination Support**: `RecordsPerPage` and `OffSet` are hardcoded - pagination won't work
4. **Same Request Every Time**: API receives identical request even during refresh
5. **TODO Comment Ignored**: Comment says "CHANGE WITH MERCHANTCONTROLLER" but never updated

### Expected Fix:
```dart
Future<Response> getItemList({
  int? storeId,
  int recordsPerPage = 50,
  int offset = 0
}) async {
  String accessToken = loginController.accessToken;
  
  Map<String, dynamic> body = {
    "StoreId": storeId ?? 1,      // Should accept parameter
    "POSId": 2,                   // Could be dynamic too
    "RecordsPerPage": recordsPerPage,
    "OffSet": offset
  };
  
  return await apiClient.postData(
    AppConstants.PRODUCT_URI, 
    body,
    authToken: accessToken
  );
}
```

---

## 4. MerchantController - getMerchantList() ✅ DATA REFRESHES

**File**: [lib/presentation/controllers/merchant_controller.dart](lib/presentation/controllers/merchant_controller.dart#L17-L48)

### Data Storage (Lines 10-12)
```dart
List<Stores> _storeList = [];
List<Stores> get storeList => _storeList;
final RxBool isLoading = false.obs;
```

### getMerchantList() Method (Lines 17-48)
```dart
Future<void> getMerchantList() async {
  isLoading.value = true;
  try {
    print("📦 [MerchantController] Starting getMerchantList()");
    
    dio.Response response = await merchantRepository.getMerchantList();

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("✅ [MerchantController] Got data. Parsing merchant model...");
      
      MerchantModel merchantModel = MerchantModel.fromJson(response.data);
      _storeList = merchantModel.stores ?? [];  // Replaces old data
      
      print("✅ [MerchantController] Number of stores loaded: ${_storeList.length}");
      update();                                 // Notifies listeners
    }
  } catch (e) {
    print("❌ [MerchantController] Error fetching store list: $e");
  } finally {
    isLoading.value = false;
  }
}
```

**Status**: ✅ **WORKS CORRECTLY**
- Data is properly replaced each time
- Provides loading state feedback
- Error handling and finally cleanup included

---

## 5. TopDashboardRepository.getTopList() ✅ SUPPORTS FRESH DATA

**File**: [lib/data/repositories/top_dashboard_repo.dart](lib/data/repositories/top_dashboard_repo.dart#L16-L31)

```dart
Future<Response> getTopList({
  required DateTime date,
  required List<int> storeIds,
}) async {
  String accessToken = loginController.accessToken;

  // ✅ GOOD: Creates FRESH body for each call
  Map<String, dynamic> body = {
    "Date": "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    "StoreIds": storeIds
  };

  return await apiClient.postData(
    AppConstants.TOP5_PRODUCT, 
    body,
    authToken: accessToken
  );
}
```

**Status**: ✅ **BEST PRACTICE**
- Creates fresh request body each time
- Supports dynamic date and storeIds parameters
- No hard-coded values

---

## 6. MerchantRepository.getMerchantList() ✅ REFRESHES PROPERLY

**File**: [lib/data/repositories/merchant_repo.dart](lib/data/repositories/merchant_repo.dart#L16-L49)

```dart
class MerchantRepository extends GetxService {
  late Map<String, dynamic> body;

  MerchantRepository({
    required this.apiClient,
    required this.loginController,
  }) {
    body = {
      "MerchantId": loginController.merchantId
    };
  }

  Future<Response> getMerchantList() async {
    String accessToken = loginController.accessToken;
    String merchantId = loginController.merchantId;

    // Uses current loginController.merchantId (good for multi-merchant apps)
    return await apiClient.postData(
      AppConstants.MERCHANTSTORE,
      body,
      authToken: accessToken
    );
  }
}
```

**Status**: ✅ **ACCEPTABLE**
- References loginController.merchantId (gets current value)
- Returns fresh API response each time

---

## 7. Pull-to-Refresh Flow

**File**: [lib/presentation/screens/sales/main_sales_page.dart](lib/presentation/screens/sales/main_sales_page.dart#L57-L64)

```dart
Future<void> _onRefresh() async {
  print("🔄 [MainSalesPage] Pull-to-refresh triggered");
  await merchantController.getMerchantList();   // ✅ Gets fresh stores
  _loadTopDashboardData();                      // ✅ Gets fresh top dashboard
  print("✅ [MainSalesPage] Pull-to-refresh completed");
}

void _loadTopDashboardData() {
  if (selectedStoreId != null) {
    topDashboardController.getTopList(
      date: selectedDate,
      storeIds: [selectedStoreId!],
    );
  }
}
```

### ItemsList.dart Pull-to-Refresh (lib/presentation/screens/items/items_list.dart#L19-22)
```dart
Future<void> _onRefresh() async {
  print("🔄 [ItemsList] Pull-to-refresh triggered");
  await itemController.getItemList();  // ✅ Calls refresh
  print("✅ [ItemsList] Pull-to-refresh completed");
}
```

**Status**: ⚠️ **ItemsList has refresh but MainSalesPage doesn't trigger ItemController refresh**
- MainSalesPage.\_onRefresh() doesn't call itemController.getItemList()
- Even if it did, the ItemRepository hardcoded parameters would prevent fresh data

---

## Summary of Issues

| Component | Status | Problem | Impact |
|-----------|--------|---------|--------|
| TopDashboardController | ✅ | None | Data refreshes correctly |
| ItemController | ⚠️ | Repository has hardcoded params | Won't get fresh data on refresh |
| MerchantController | ✅ | None | Data refreshes correctly |
| TopDashboardRepo | ✅ | None | Creates fresh requests with dynamic params |
| ItemRepository | 🔴 **CRITICAL** | Hardcoded body, static params | Always sends same request, makes refresh useless |
| MerchantRepository | ✅ | None | Refreshes properly |
| Refresh Flow | ⚠️ | ItemController not called in MainSalesPage refresh | Items never refresh during pull-to-refresh |

---

## Root Cause: ItemRepository Hardcoding

The **primary issue** is in [lib/data/repositories/item_repo.dart](lib/data/repositories/item_repo.dart#L15-22):

```dart
// THIS IS THE PROBLEM:
Map<String, dynamic> body = {
  "StoreId": 1,
  "POSId": 2,
  "RecordsPerPage": 3,
  "OffSet": 4
};
```

- Initialized once at instantiation
- Never changes
- Every API call gets the same hardcoded values
- Makes pull-to-refresh ineffective for items

---

## Caching vs. Refresh

**Current Behavior**:
- No explicit caching layer exists
- Data is stored in controller variables
- `update()` is called to notify GetX listeners
- Data refresh depends on API returning different responses
- **Problem**: ItemRepository doesn't support fresh API calls

**What Should Happen**:
- ItemRepository should accept dynamic parameters
- Each refresh call should send different request body
- API response is mapped to model and stored
- UI listeners notified of changes

---

## Recommendations

1. **Fix ItemRepository immediately** - Remove hardcoded parameters
2. **Update ItemController** to support store selection
3. **Add ItemController refresh to MainSalesPage.\_onRefresh()**
4. **Consider adding caching layer** if API performance is a concern
5. **Use GetBuilder properly** - Ensure all screens using GetBuilder<ItemController>
