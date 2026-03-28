class AppConstants {
  static const String APP_NAME = 'ShoppazingDashboard';
  static const int APP_VERSION = 1;

  static const String BASE_URL =
      "http://jaramburo19-001-site11.ftempurl.com/api/";

  static const String SENDOTP = "shop/sendotp";
  static const String SENDOTP_FALLBACK = "otp/send-otp";
  static const String VERIFYOTP = "shop/verifyotplogin";
  static const String VERIFYOTP_FALLBACK = "shop/verifyotp";
  static const String VERYPIN = "shop/loginbypin";
  static const String CHANGE_PASSWORD = "Account/ChangePassword";
  static const String PRODUCT_URI = "shop/getstoreitemsbystoreidByPage";
  static const String TOP5_PRODUCT = "shop/getMerchantDashboardData";
  static const String MERCHANTSTORE = "shop/GetMerchantStoresByMerchantId";

  static const String OTP_APP_HASH = String.fromEnvironment(
    'OTP_APP_HASH',
    defaultValue: 'XMsemExH',
  );
  static const String OTP_ISSUER = String.fromEnvironment(
    'OTP_ISSUER',
    defaultValue: 'Shoppazing',
  );
  static const String OTP_AUDIENCE = String.fromEnvironment(
    'OTP_AUDIENCE',
    defaultValue: 'ShoppazingDashboard',
  );
  static const String OTP_ENCRYPTED_SECRET_KEY = String.fromEnvironment(
    'OTP_ENCRYPTED_SECRET_KEY',
    defaultValue: '',
  );

  static const String TOKEN_URL = "${BASE_URL}token";
  static String getTokenUrl() {
    return Uri.parse("${BASE_URL}token").toString();
  }
}
