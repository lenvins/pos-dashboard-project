import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_dashboard/core/utils/password_validator.dart';
import 'package:pos_dashboard/data/repositories/change_password_repo.dart';

class ChangePasswordController extends GetxController {
  final ChangePasswordRepo repo;

  ChangePasswordController({required this.repo}) : super();

  final TextEditingController currentPwdController = TextEditingController();
final RxBool showCurrentPwd = false.obs;
  final RxBool showNewPwd = false.obs;
  final RxBool showConfirmPwd = false.obs;
  final TextEditingController newPwdController = TextEditingController();
  final TextEditingController confirmPwdController = TextEditingController();

  @override
  void onInit() {
    ever(showCurrentPwd, (_) => print('Current pwd visibility: ${showCurrentPwd.value}'));
    ever(showNewPwd, (_) => print('New pwd visibility: ${showNewPwd.value}'));
    ever(showConfirmPwd, (_) => print('Confirm pwd visibility: ${showConfirmPwd.value}'));
    super.onInit();
    newPwdController.addListener(_onNewPwdChanged);
    confirmPwdController.addListener(_onConfirmPwdChanged);
    currentPwdController.addListener(_onCurrentPwdChanged);
  }

  final RxString newPwdStrength = ''.obs;
  final Rx<PasswordStrength> strength = PasswordStrength.weak.obs;
  final RxBool isNewConfirmMatch = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString currentPwdError = ''.obs;



  @override
  void onClose() {
    currentPwdController.dispose();
    newPwdController.dispose();
    confirmPwdController.dispose();
    super.onClose();
  }

  void _onNewPwdChanged() {
    final pwd = newPwdController.text;
    strength.value = PasswordValidator.getStrength(pwd);
    newPwdStrength.value = PasswordValidator.getStrengthText(strength.value);
    _checkConfirmMatch();
  }

  void _onConfirmPwdChanged() {
    _checkConfirmMatch();
  }

  void _onCurrentPwdChanged() {
    if (currentPwdError.value.isNotEmpty) {
      currentPwdError.value = '';
    }
  }

  void _checkConfirmMatch() {
    isNewConfirmMatch.value = newPwdController.text == confirmPwdController.text;
  }

  Future<bool> changePassword() async {
    // Validate all fields are filled
    if (currentPwdController.text.isEmpty) {
      errorMessage.value = 'Please enter your current password';
      return false;
    }
    
    if (newPwdController.text.isEmpty) {
      errorMessage.value = 'Please enter a new password';
      return false;
    }
    
    if (confirmPwdController.text.isEmpty) {
      errorMessage.value = 'Please confirm your new password';
      return false;
    }

    // Validate password confirmation matches
    if (!isNewConfirmMatch.value) {
      errorMessage.value = 'New password and confirmation do not match';
      return false;
    }

    // Validate password strength
    if (strength.value == PasswordStrength.weak) {
      errorMessage.value = 'Password is too weak. Please use a stronger password';
      return false;
    }

    // Validate new password is different from current
    if (currentPwdController.text == newPwdController.text) {
      errorMessage.value = 'New password must be different from current password';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    final result = await repo.changePassword(
      currentPassword: currentPwdController.text,
      newPassword: newPwdController.text,
      confirmPassword: confirmPwdController.text,
    );

    isLoading.value = false;

    if (result['success']) {
      Get.snackbar(
        'Success',
        result['message'] ?? 'Password changed successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      clearForm();
      return true;
    } else {
      String message = result['message'] ?? 'Failed to change password';
      if (message.toLowerCase().contains('current password') ||
          message.toLowerCase().contains('wrong current') ||
          message.toLowerCase().contains('current password is incorrect') ||
          message.toLowerCase().contains('invalid current') ||
          message.toLowerCase().contains('invalid current password')) {
        message = 'Invalid Current Password';
      }
      if (message == 'Invalid Current Password') {
        currentPwdError.value = 'Invalid Current Password';
        errorMessage.value = ''; // Clear general error
      } else {
        errorMessage.value = message;
        currentPwdError.value = ''; // Clear specific error
      }
      return false;
    }
  }

  void clearForm() {
    currentPwdController.clear();
    newPwdController.clear();
    confirmPwdController.clear();
    strength.value = PasswordStrength.weak;
    newPwdStrength.value = '';
    isNewConfirmMatch.value = false;
    errorMessage.value = '';
    currentPwdError.value = '';
  }
}

