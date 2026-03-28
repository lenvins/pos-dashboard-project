import 'dart:convert';

import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:pos_dashboard/data/models/login_model.dart';
import 'package:pos_dashboard/data/models/verify_otp_model.dart';
import 'package:pos_dashboard/data/models/verify_pin_model.dart';
import 'package:pos_dashboard/data/repositories/send_otp_repo.dart';
import 'package:pos_dashboard/data/repositories/verify_otp_repo.dart';
import 'package:pos_dashboard/data/repositories/verify_pin_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_dashboard/data/repositories/login_repo.dart';

class LoginController extends GetxController {
  final LoginRepository loginRepository;
  final _prefs = SharedPreferences.getInstance();

  //RX for reactive state management
  final RxString _accessToken = RxString('');
  final RxBool isPinSetup = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isOTPRequired = false.obs;
  final Rx<Map<String, String>> tempCredentials = Rx<Map<String, String>>({});
  

  final Rx<LoginModel?> loginData = Rx<LoginModel?>(null);

  String get accessToken => _accessToken.value;
  String get userId => loginData.value?.userId ?? '';
  String get phoneNumber => loginData.value?.phoneNumber ?? '';
  String get merchantId => loginData.value?.merchantId ?? '';
  String get userName => loginData.value?.userName ?? '';
  String get businessName => loginData.value?.businessName ?? '';

  LoginController( 
    {
      required this.loginRepository
    }
  );

  @override
  void onInit() {
    super.onInit();
    clearStoredData();
  }

  Future<void> clearStoredData() async {
    final prefs = await _prefs;
    await prefs.clear();
    isPinSetup.value = false;
    _accessToken.value = '';
    loginData.value = null;
    tempCredentials.value = {};
  }

  Future<String> getInitialRoute() async {
    try {
      final prefs = await _prefs;
      isPinSetup.value = prefs.getBool('isPinSetup') ?? false;
      String? storedToken = prefs.getString('access_token');
      String? storedLoginData = prefs.getString('loginData');

      if (isPinSetup.value && storedToken != null && storedToken.isNotEmpty && storedLoginData != null) {
        _accessToken.value = storedToken;

        loginData.value = LoginModel.fromJson(jsonDecode(storedLoginData));
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

  Future<void> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      errorMessage.value = "Please enter username and password";
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await loginRepository.login(username, password);

      if (response.statusCode == 200) {
        // Store response data in loginData
        if (response.data != null) {
          loginData.value = LoginModel.fromJson(response.data);
          
          // Use access token from login response
          if (response.data['access_token'] != null) {
            _accessToken.value = response.data['access_token'];
          }

          if (_accessToken.value.isEmpty &&
              loginData.value?.accessToken != null &&
              loginData.value!.accessToken!.isNotEmpty) {
            _accessToken.value = loginData.value!.accessToken!;
          }

          final prefs = await _prefs;
          await prefs.setString('access_token', _accessToken.value);
          await prefs.setString('loginData', jsonEncode(loginData.value));

          // Store credentials temporarily for OTP verification
          tempCredentials.value = {
            'username': username,
            'password': password
          };

          // Send OTP to user's phone
          await _sendOTPForVerification();
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
          error = "Server error. Please try again later";
        }
      }
      errorMessage.value = error;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _sendOTPForVerification() async {
    try {
      final sendOtpRepo = Get.find<SendOtpRepo>();
      isOTPRequired.value = true;

      print("📱 Starting OTP Send Process");
      print("Phone Number: $phoneNumber");
      print("User ID: $userId");
      print("Access Token: ${_accessToken.value.isNotEmpty ? 'Present' : 'Empty'}");

      if (phoneNumber.isEmpty) {
        errorMessage.value = "Phone number not found. Please contact support.";
        print("❌ ERROR: Phone number is empty");
        isOTPRequired.value = false;
        return;
      }

      if (userId.isEmpty) {
        errorMessage.value = "User ID not found. Please contact support.";
        print("❌ ERROR: User ID is empty");
        isOTPRequired.value = false;
        return;
      }

      final response = await sendOtpRepo.getSendOTP(
        phoneNumber: phoneNumber,
        userId: userId,
        accessToken: accessToken
      );

      print("📤 OTP Send API Response:");
      print("Status: ${response.statusCode}");
      print("Data: ${response.data}");

      // Check if API returned success (various status codes possible)
      if (response.statusCode == 200 || 
          response.statusCode == 201 || 
          (response.data != null && response.statusCode! < 300)) {
        print("✅ OTP sent successfully!");
        Get.offAllNamed('/otp-verification');
      } else {
        print("❌ OTP Send Failed - Status: ${response.statusCode}");
        print("Response: ${response.data}");
        errorMessage.value = "Failed to send OTP. Please try again.";
        isOTPRequired.value = false;
      }
    } catch (e) {
      print("❌ Error sending OTP: $e");
      errorMessage.value = "Failed to send OTP: ${e.toString()}";
      isOTPRequired.value = false;
    }
  }

  Future<void> verifyOTP(String otp) async {
    final verifyOtpRepo = Get.find<VerifyOtpRepo>();
    
    if (otp.isEmpty || otp.length != 6) {
      errorMessage.value = "Please enter a valid 6-digit OTP";
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      print("Verifying OTP: $otp");
      print("Access Token: $accessToken");
      print("User ID: $userId");
      print("Phone Number: $phoneNumber");
      
      final response = await verifyOtpRepo.getVerifyOTP(otp);

      print("OTP Response Status: ${response.statusCode}");
      print("OTP Response Data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final verifyOTPModel = VerifyOTPModel.fromJson(response.data);
        
        print("Parsed Status Code: ${verifyOTPModel.statusCode}");
        print("Parsed Message: ${verifyOTPModel.message}");
        print("Parsed UserId: ${verifyOTPModel.userId}");
        
        // Accept various success status codes
        if ((verifyOTPModel.statusCode == 200 || 
             verifyOTPModel.statusCode == 0 || 
             verifyOTPModel.statusCode == 1 ||
             verifyOTPModel.statusCode == null) &&
            (response.statusCode ?? 500) < 300) {
          
          // OTP verification successful - proceed with login
          dio.Response loginResponse = await loginRepository.login(
            tempCredentials.value['username'] ?? '',
            tempCredentials.value['password'] ?? '',
          );

          print("Login Response Status: ${loginResponse.statusCode}");

          if ((loginResponse.statusCode ?? 500) == 200 && loginResponse.data != null) {
            loginData.value = LoginModel.fromJson(loginResponse.data);
            _accessToken.value = loginResponse.data['access_token'] ?? _accessToken.value;

            final prefs = await _prefs;
            await prefs.setString('access_token', _accessToken.value);
            await prefs.setString('loginData', jsonEncode(loginData.value));

            isOTPRequired.value = false;
            Get.offAllNamed('/dashboard');
          } else {
            errorMessage.value = "Login failed after OTP verification. Please try again."; 
          }
        } else {
          errorMessage.value = verifyOTPModel.message ?? "Invalid OTP. Please try again.";
        }
      } else if (response.statusCode == 500) {
        // Server error - likely model mismatch
        String errorMsg = "Server error";
        if (response.data != null) {
          if (response.data['Message'] != null) {
            errorMsg = response.data['Message'];
          }
          if (response.data['ExceptionMessage'] != null) {
            errorMsg = response.data['ExceptionMessage'];
          }
        }
        errorMessage.value = "Verification error: $errorMsg";
        print("❌ Server Error: $errorMsg");
      } else {
        errorMessage.value = "OTP verification failed. Server error. Please try again.";
      }
    } catch (e) {
      print("OTP verification error: $e");
      errorMessage.value = "OTP verification error: ${e.toString()}";
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
            final prefs = await _prefs;
            await prefs.setBool('isPinSetup', true);
            isPinSetup.value = true;
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

  Future<void> logout() async {
    await clearStoredData();
    Get.offAllNamed('/');
  }

  Future<void> resendOTP() async {
    final sendOtpRepo = Get.find<SendOtpRepo>();
    isLoading.value = true;
    errorMessage.value = '';
    try {
      print("Resending OTP to: $phoneNumber");
      final response = await sendOtpRepo.getSendOTP(
        phoneNumber: phoneNumber,
        userId: userId,
        accessToken: accessToken
      );
      
      print("Resend OTP Response: ${response.statusCode}");
      print("Resend OTP Data: ${response.data}");
      
      await Future.delayed(const Duration(seconds: 2));
      Get.snackbar(
        'Success',
        'OTP has been resent to your mobile phone',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error resending OTP: $e");
      errorMessage.value = "Failed to resend OTP. Please try again";
    } finally {
      isLoading.value = false;
    }
  }
}
