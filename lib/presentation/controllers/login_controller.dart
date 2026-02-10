import 'dart:convert';
import 'dart:math';

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
        tempCredentials.value = {'username': username, 'password': password};
        
        // Store response data in loginData
        if (response.data != null) {
          loginData.value = LoginModel.fromJson(response.data);
          
          // Check if there's a temporary access token in the initial login response
          if (response.data['access_token'] != null) {
            _accessToken.value = response.data['access_token'];
          }
        }

        // Get the SendOtpRepo and call getSendOTP with the current phone number and userId
        final sendOtpRepo = Get.find<SendOtpRepo>();
        await sendOtpRepo.getSendOTP(
          phoneNumber: loginData.value?.phoneNumber,
          userId: loginData.value?.userId,
          accessToken: _accessToken.value
        );

        isOTPRequired.value = true;
        Get.toNamed('/otp-verification');
      } else {
        errorMessage.value = "Login failed. Please check your credentials.";
      }
    } catch (e) {
      String error = "Login failed. Please try again";

      if (e is dio.DioException) {
        if (e.response?.statusCode == 400) {
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

  Future<void> verifyOTP(String otp) async {
    final verifyOtpRepo = Get.find<VerifyOtpRepo>();
    
    if (otp.isEmpty) {
      errorMessage.value = "Please enter OTP";
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await verifyOtpRepo.getVerifyOTP(otp);

      if (response.statusCode == 200 || response.statusCode == 201) {

        final verifyOTPModel = VerifyOTPModel.fromJson(response.data);
        
        if (verifyOTPModel.statusCode == 200 || verifyOTPModel.statusCode == 0) {
          if (verifyOTPModel.userId != null) {
            if (loginData.value == null) {
              loginData.value = LoginModel();
            }

            loginData.value!.userId = verifyOTPModel.userId!;

            dio.Response loginResponse = await loginRepository.login(
              tempCredentials.value['username']!,
              tempCredentials.value['password']!,
            );

            if (loginResponse.statusCode == 200 && loginResponse.data != null) {
              loginData.value = LoginModel.fromJson(loginResponse.data);
              _accessToken.value = loginResponse.data['access_token'];

              final prefs = await _prefs;
              await prefs.setString('access_token', _accessToken.value);
              await prefs.setString('loginData', jsonEncode(loginData.value));

              Get.toNamed('/pin-verification');
            } else {
              errorMessage.value = "Login failed. Please try again."; 
            }
          } else {
            errorMessage.value = "Missing user information.";
          }
        } else {
          errorMessage.value = verifyOTPModel.message ?? "Invalid OTP";
        }
      } else {
        errorMessage.value = "OTP verification failed. Please try again.";
      }
    } catch (e) {
      errorMessage.value = "OTP verification failed. Please try again.";
      print("OTP verification error: $e");
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
      await sendOtpRepo.getSendOTP(
        phoneNumber: phoneNumber,
        userId: userId,
        accessToken: accessToken
      );
      
      await Future.delayed(const Duration(seconds: 2));
      Get.snackbar(
        'Success',
        'OTP has been resent to your mobile phone',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = "Failed to resend OTP. Please try again";
    } finally {
      isLoading.value = false;
    }
  }
}