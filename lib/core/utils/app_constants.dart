class AppConstants {
  static const String APP_NAME = 'ShoppazingDashboard';
  static const int APP_VERSION = 1;

  static const String BASE_URL = "http://jaramburo19-001-site11.ftempurl.com/api/";

  static const String SENDOTP = "shop/sendotp";
  static const String VERIFYOTP = "shop/verifyotplogin";
  static const String VERYPIN = "shop/loginbypin";
  static const String PRODUCT_URI = "/shop/getstoreitemsbystoreidByPage";
  static const String TOP5_PRODUCT = "/shop/getMerchantDashboardData";
  static const String MERCHANTSTORE = "/shop/GetMerchantStoresByMerchantId";

  static const String TOKEN_URL = "$BASE_URL/token";
  static String getTokenUrl() {
    return Uri.parse("$BASE_URL/token").toString();
  }

}


