import 'package:get/get.dart';
import 'package:flutter_application_1/app/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    Future.delayed(const Duration(seconds: 1), () {
      Get.offAllNamed(Routes.HOME);
    });
  }
}
