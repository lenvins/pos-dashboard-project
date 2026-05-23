import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class ActivityWrapper extends StatelessWidget {
  final Widget child;
  final bool showLoading;

  const ActivityWrapper({
    super.key,
    required this.child,
    this.showLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final loginController = Get.find<LoginController>();

    return Stack(
      children: [
        child,
        Obx(() => loginController.isLoading.value
            ? Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : const SizedBox.shrink()),
      ],
    );
  }
}

