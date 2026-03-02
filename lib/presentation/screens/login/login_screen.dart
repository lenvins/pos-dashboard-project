import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_dashboard/core/utils/dimensions.dart';
import 'package:pos_dashboard/presentation/controllers/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController loginController = Get.find();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Color primaryColor = const Color(0xFF00308F);
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Dimensions.height16),
          child: Column(
            children: [
              Image.asset('assets/image/shoppazingnobg.png', height: 130, width: 130),
              Image.asset('assets/image/shoppazingdashboard.png', height: 80, width: 250),
            
              TextField(
                controller: usernameController,
                style: const TextStyle(color: Colors.black),
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: primaryColor),
                  prefixIcon: Icon(Icons.person, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                style: const TextStyle(color: Colors.black),
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: primaryColor),
                  prefixIcon: Icon(Icons.lock, color: primaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: primaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Obx(() {
                // Show error message if any
                if (loginController.errorMessage.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      loginController.errorMessage.value,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed:
                        loginController.isLoading.value
                            ? null
                            : () => loginController.login(
                              usernameController.text,
                              passwordController.text,
                            ),
                    child:
                        loginController.isLoading.value
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
