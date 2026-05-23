import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_dashboard/core/utils/dimensions.dart';
import 'package:pos_dashboard/notification/notification_service.dart';
import 'package:pos_dashboard/presentation/screens/settings/terms_webview_screen.dart';
import 'package:pos_dashboard/presentation/controllers/theme_controller.dart';
import 'package:pos_dashboard/presentation/controllers/login_controller.dart';
import 'package:pos_dashboard/presentation/controllers/change_password_controller.dart';
import 'package:pos_dashboard/core/utils/password_validator.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ChangePasswordController changePwdController = Get.find<ChangePasswordController>();

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Obx(() => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.lock, color: Colors.blue[900], size: 28),
              const SizedBox(width: 12),
              const Text(
                'Change Password',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          content: SizedBox(
            height: 420,
            width: 360,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPasswordField(
                    controller: changePwdController.currentPwdController,
                    label: 'Current Password',
                    icon: Icons.lock,
                    showPwd: changePwdController.showCurrentPwd,
                    errorText: changePwdController.currentPwdError,
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    controller: changePwdController.newPwdController,
                    label: 'New Password',
                    icon: Icons.lock_open,
                    showPwd: changePwdController.showNewPwd,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: changePwdController.strength.value == PasswordStrength.strong
                          ? Colors.green.withOpacity(0.1)
                          : changePwdController.strength.value == PasswordStrength.medium
                              ? Colors.orange.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: changePwdController.strength.value == PasswordStrength.strong
                            ? Colors.green
                            : changePwdController.strength.value == PasswordStrength.medium
                                ? Colors.orange
                                : Colors.red,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.security,
                          size: 24,
                          color: changePwdController.strength.value == PasswordStrength.strong
                              ? Colors.green
                              : changePwdController.strength.value == PasswordStrength.medium
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          changePwdController.newPwdStrength.value,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: changePwdController.strength.value == PasswordStrength.strong
                                ? Colors.green
                                : changePwdController.strength.value == PasswordStrength.medium
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    controller: changePwdController.confirmPwdController,
                    label: 'Confirm New Password',
                    icon: Icons.lock_reset,
                    showPwd: changePwdController.showConfirmPwd,
                  ),
                  const SizedBox(height: 12),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: changePwdController.isNewConfirmMatch.value 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: changePwdController.isNewConfirmMatch.value 
                            ? Colors.green
                            : Colors.red,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          changePwdController.isNewConfirmMatch.value 
                              ? Icons.check_circle
                              : Icons.error,
                          color: changePwdController.isNewConfirmMatch.value 
                              ? Colors.green
                              : Colors.red,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            changePwdController.isNewConfirmMatch.value 
                                ? 'Passwords match ✓'
                                : 'Passwords do not match ✗',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: changePwdController.isNewConfirmMatch.value 
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (changePwdController.errorMessage.value.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.red, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              changePwdController.errorMessage.value,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(
              width: 140,
              child: changePwdController.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      onPressed: changePwdController.isLoading.value ? null : _handlePasswordUpdate,

                      child: const Text(
                        'Update Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ],
        ));
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required RxBool showPwd,
    RxString? errorText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: !showPwd.value,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Get.isDarkMode ? Colors.black : Colors.black),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue[700], size: 24),
          suffixIcon: Obx(() => IconButton(
            padding: const EdgeInsets.only(right: 12),
            icon: Icon(
              showPwd.value ? Icons.visibility : Icons.visibility_off,
              color: Colors.blue[700],
              size: 24,
            ),
            onPressed: () {
              print('Toggling password field: ${showPwd.value} -> ${!showPwd.value}');
              showPwd.value = !showPwd.value;
            },
          )),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          filled: true,
          fillColor: Colors.transparent,
          errorText: errorText?.value,
        ),
      ),
    );
  }

  void _showPasswordChangedDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.blue[900]!, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 18),
              Icon(Icons.done_all_rounded, size: 60, color: Colors.blue[900]),
              const SizedBox(height: 16),
              const Text(
                'Password Updated',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your password has been changed successfully. You can stay logged in or log out now.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Stay Logged In',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        Get.find<LoginController>().logout();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.blue[900]!),
                        foregroundColor: Colors.blue[900],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Log Out',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _handlePasswordUpdate() async {
    final success = await changePwdController.changePassword();
    if (!mounted) return;
    if (success) {
      Get.back();
      _showPasswordChangedDialog();
    }
  }

  Future<void> _handleTestNotification() async {
    await NotificationService().showImmediateNotification(
      id: 0,
      title: 'Test Notification',
      body: 'This is a test notification. From settings_screen.dart',
    );
    if (!mounted) return;
    Get.snackbar(
      'Success',
      'Test notification sent!',
      backgroundColor: Colors.blue[900],
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void initState() {
    super.initState();
    // Controller already available via lazyPut/fenix in dependencies.dart
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();


    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 16),
          Obx(
            () => SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: Text(
                themeController.isDarkMode
                    ? 'Dark theme enabled'
                    : 'Light theme enabled',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              value: themeController.isDarkMode,
              onChanged: (_) => themeController.toggleTheme(),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              leading: Icon(Icons.lock, color: Theme.of(context).primaryColor, size: 28),
              title: const Text(
                'Change Password',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text(
                'Update your account password securely',
                style: TextStyle(color: Colors.grey),
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onTap: () => _showChangePasswordDialog(context),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Test Notification'),
            subtitle: const Text('Send a test notification to verify functionality'),
            trailing: ElevatedButton(
              onPressed: _handleTestNotification,

              child: const Text('Test'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsWebviewScreen(
                          url: 'https://sellercenter.shoppazing.com/home/terms',
                          title: 'Terms and Conditions',
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Terms and Conditions',
                    style: TextStyle(fontSize: Dimensions.font12),
                  ),
                ),
                Text(' · ', style: TextStyle(fontSize: Dimensions.font18)),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsWebviewScreen(
                          url: 'https://sellercenter.shoppazing.com/home/privacy',
                          title: 'Privacy Policy',
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Privacy Policy',
                    style: TextStyle(fontSize: Dimensions.font12),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              Get.find<LoginController>().logout();
            },
            child: BottomAppBar(
              child: SizedBox(
                height: Dimensions.height50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text('LOGOUT')],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> scheduleDailyReminder() async {
  await NotificationService().scheduleDailyNotification(
    id: 1,
    title: 'Daily Reminder',
    body: 'Don\'t forget to view your daily statistics!',
    scheduledTime: const TimeOfDay(hour: 8, minute: 0),
  );
}

