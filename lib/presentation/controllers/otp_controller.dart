import 'package:get/get.dart';
import 'dart:async';

class OTPController extends GetxController {
  Timer? _timer;
  final RxInt timeLeft = 300.obs;
  final RxBool isExpired = false.obs;

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void startTimer() {
    isExpired.value = false;
    timeLeft.value = 300;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft.value > 0) {
        timeLeft.value--;
      } else {
        isExpired.value = true;
        timer.cancel();
      }
    });
  }

  String getFormattedTime() {
    int minutes = timeLeft.value ~/ 60;
    int seconds = timeLeft.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
