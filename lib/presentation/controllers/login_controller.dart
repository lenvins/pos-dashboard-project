import 'dart:convert';
import 'dart:async';

import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:pos_dashboard/data/models/login_model.dart';
import 'package:pos_dashboard/data/models/verify_otp_model.dart';
import 'package:pos_dashboard/data/models/verify_pin_model.dart';
import 'package:pos_dashboard/data/repositories/send_otp_repo.dart';
import 'package:pos_dashboard/data/repositories/verify_otp_repo.dart';
import 'package:pos_dashboard/data/repositories/verify_pin_repo.dart';
import 'package:pos_dashboard/data/repositories/login_repo.dart';
import 'package:pos_dashboard/data/repositories/change_password_repo.dart';

class LoginController extends GetxController with WidgetsBindingObserver {
  // Background-based session tracking
  final Rx<Duration> totalBackgroundTime = Duration.zero.obs;
  DateTime? _pauseTime;
  final Rx<DateTime?> lastActivityTime = Rx<DateTime?>(null); // Keep for compatibility if needed

  final LoginRepository loginRepository;

  //RX for reactive state management
  final RxString _accessToken = ''.obs;
  final RxBool isPinSetup = false.obs;
  final RxBool isPinVerified = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isOTPRequired = false.obs;
  final RxMap<String, String> tempCredentials = <String, String>{}.obs;
  
  // Session expiry
  static const Duration SESSION_TIMEOUT = Duration(minutes: 5);

  final Rx<LoginModel?> loginData = Rx<LoginModel?>(null);

  String get accessToken => _accessToken.value;
  String get userId => loginData.value?.userId ?? '';
  String get phoneNumber => loginData.value?.phoneNumber ?? '';
  String get merchantId => loginData.value?.merchantId ?? '';
  String get userName => loginData.value?.userName ?? '';
  String get businessName => loginData.value?.businessName ?? '';

  LoginController({ 
    required this.loginRepository
  });

  bool get isSessionExpired {
    return totalBackgroundTime.value > SESSION_TIMEOUT;
  }

  /// Reset background accumulator on user activity (called from GestureDetector)
  void resetBackgroundTime() {
    totalBackgroundTime.value = Duration.zero;
  }

  Future<void> checkSessionExpiry() async {
    if (isSessionExpired) {
      // Only show expiry if actually background time accumulated
      if (totalBackgroundTime.value > Duration(minutes: 4)) {
        await logout(showExpiryDialog: true);
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadLastActivity(); // Keep for legacy
    // No periodic timer needed for background-only expiry
  }

@override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pauseTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_pauseTime != null) {
        final backgroundDuration = DateTime.now().difference(_pauseTime!);
        totalBackgroundTime.value += backgroundDuration;
        _pauseTime = null;
      }
      // Always check on resume, activity wrapper will reset on touches
      checkSessionExpiry();
    }
  }

  Future<void> _loadLastActivity() async {
    final box = GetStorage();
    String? timeStr = box.read('last_activity');
    if (timeStr != null) {
      try {
        lastActivityTime.value = DateTime.parse(timeStr);
      } catch (e) {
        lastActivityTime.value = null;
      }
    }
  }

  Future<void> clearStoredData() async {
    final box = GetStorage();
    box.erase();
    isPinSetup.value = false;
    isPinVerified.value = false;
    _accessToken.value = '';
    loginData.value = null;
    tempCredentials.value = {};
  }

  Future<String> getInitialRoute() async {
    try {
      final box = GetStorage();
      isPinSetup.value = box.read('isPinSetup') ?? false;
      isPinVerified.value = box.read('isPinVerified') ?? false;
      String? storedToken = box.read('access_token');
      String? storedLoginData = box.read('loginData');

      if (isPinSetup. value && storedToken != null && storedToken.isNotEmpty && storedLoginData != null) {
        _accessToken.value = storedToken;
        loginData.value = LoginModel.fromJson(jsonDecode(storedLoginData));
        await _loadLastActivity();
        await checkSessionExpiry();
        if (isSessionExpired) {
          return '/';
        }
        // If PIN is already verified, go directly to dashboard
        if (isPinVerified.value) {
          return '/dashboard';
        }
        return '/pin-verification';
      }

      await clearStoredData();
      return '/';
    } catch (e) {
      print('Error checking initial route: $e');
      await clearStoredData();
      return '/';
    }
  }

  String? loginPassword;
  Future<void> login(String username, String password) async {
    loginPassword = password;
    if (username.isEmpty || password.isEmpty) {
      errorMessage.value = "Please enter username and password";
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await loginRepository.login(username, password);

      if (response.statusCode == 200) {
        if (response.data != null) {
          loginData.value = LoginModel.fromJson(response.data);
          
          if (response.data['access_token'] != null) {
            _accessToken.value = response.data['access_token'];
          }

          if (_accessToken.value.isEmpty &&
              loginData.value?.accessToken != null &&
              loginData.value!.accessToken!.isNotEmpty) {
            _accessToken.value = loginData.value!.accessToken!;
          }

          final box = GetStorage();
          box.write('access_token', _accessToken.value);
          box.write('loginData', jsonEncode(loginData.value));
          // Don't reset isPinSetup here, check if it's already set
          bool pinAlreadySetup = box.read('isPinSetup') ?? false;
          if (!pinAlreadySetup) {
            box.write('isPinSetup', false);
          }

          tempCredentials.value = {
            'username': username,
            'password': password
          };

          isOTPRequired.value = false;
          // If PIN is already set up, go to PIN verification, otherwise go to dashboard
          if (pinAlreadySetup) {
            Get.offAllNamed('/pin-verification');
          } else {
            Get.offAllNamed('/dashboard');
          }
        }
      } else {
        errorMessage.value = "Login failed. Please check your credentials.";
      }
    } catch (e) {
      String error = "Login failed. Please try again";

      if (e is dio.DioException) {
        if (e.type == dio.DioExceptionType.connectionError ||
            e.type == dio.DioExceptionType.connectionTimeout ||
            e.type == dio.DioExceptionType.receiveTimeout ||
            e.type == dio.DioExceptionType.sendTimeout) {
          error = "No internet connection. Please check your network.";
        } else if (e.response?.statusCode == 400) {
          error = "Invalid username or password";
        } else if (e.response?.statusCode == 500) {
          error = "Server error. Please try again later.";
        }
      }
      errorMessage.value = error;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyPin(String pin) async {
    final verifyPinRepo = Get.find<VerifyPinRepo>();
    if (pin.isEmpty) {
      errorMessage.value = "Please enter PIN";
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await verifyPinRepo.getVerifyPin(pin);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final verifyPINModel = VerifyPINModel.fromJson(response.data);

        if (verifyPINModel.statusCode == 200 || verifyPINModel.statusCode == 0) {
          if (verifyPINModel.message?.toLowerCase() == "success") {
            final box = GetStorage();
            box.write('isPinSetup', true);
            box.write('isPinVerified', true);
            isPinSetup.value = true;
            isPinVerified.value = true;
            Get.offAllNamed('/dashboard');
          } else {
            errorMessage.value = verifyPINModel.message ?? "PIN Verification failed";
          }
        } else {
          errorMessage.value = verifyPINModel.message ?? "Invalid PIN";
        }
      } else {
        errorMessage.value = "PIN Verification failed. Please try again.";
      }
    } catch (e) {
      errorMessage.value = "PIN Verification failed. Please try again.";
      print("PIN verification error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout({bool showExpiryDialog = false}) async {
    await clearStoredData();
    if (showExpiryDialog) {
      Get.dialog(
        _buildExpiryDialog(),
        barrierDismissible: false,
      );
    } else {
      Get.offAllNamed('/');
    }
  }

  Widget _buildExpiryDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue[900]!, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.blue[900]!.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.timer_off_outlined,
                size: 48,
                color: Colors.blue[900],
              ),
            ),

            SizedBox(height: 16),
            Text(
              'Session Login Expired',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
                fontFamily: 'Roboto',
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Your session has expired after 5 minutes of inactivity. Please log in again.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                  fontFamily: 'Roboto',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.offAllNamed('/');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Log in Again',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
