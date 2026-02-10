import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pos_dashboard/core/utils/dimensions.dart';
import 'package:pos_dashboard/presentation/controllers/login_controller.dart';

class PinVerificationScreen extends GetView<LoginController> {
  PinVerificationScreen({super.key});

  final List<TextEditingController> pinControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  final Color primaryColor = const Color(0xFF00308F);

  String getPin() {
    return pinControllers.map((controller) => controller.text).join();
  }

  void clearPinFields() {
    for (var controller in pinControllers) {
      controller.clear();
    }
    focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(
      builder:
          (loginController) => WillPopScope(
            onWillPop: () async => !loginController.isPinSetup.value,
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(Dimensions.height16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/image/logo.png',
                        height: 140,
                        width: 140,
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'Enter PIN',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00308F),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Please enter your 6-digit PIN',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          6,
                          (index) => SizedBox(
                            width: 45,
                            height: 45,
                            child: TextField(
                              controller: pinControllers[index],
                              focusNode: focusNodes[index],
                              obscureText: true,
                              decoration: InputDecoration(
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: primaryColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: primaryColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(1),
                              ],
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 5) {
                                  focusNodes[index + 1].requestFocus();
                                }
                                if (value.isEmpty && index > 0) {
                                  focusNodes[index - 1].requestFocus();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Error message
                      GetX<LoginController>(
                        builder: (controller) {
                          if (controller.errorMessage.value.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                controller.errorMessage.value,
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      // Verify/Set PIN button
                      GetX<LoginController>(
                        builder:
                            (controller) => SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed:
                                    controller.isLoading.value
                                        ? null
                                        : () {
                                          controller.verifyPin(getPin()).then((
                                            _,
                                          ) {
                                            if (controller
                                                .errorMessage
                                                .value
                                                .isNotEmpty) {
                                              clearPinFields();
                                            }
                                          });
                                        },
                                child:
                                    controller.isLoading.value
                                        ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                        : Text(
                                          controller.isPinSetup.value
                                              ? "Login with PIN"
                                              : "Set PIN",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                              ),
                            ),
                      ),

                      // Reset PIN button
                      GetX<LoginController>(
                        builder: (controller) {
                          if (controller.isPinSetup.value) {
                            return Column(
                              children: [
                                const SizedBox(height: 20),
                                TextButton(
                                  onPressed: () => controller.logout(),
                                  child: Text(
                                    "Reset PIN",
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
