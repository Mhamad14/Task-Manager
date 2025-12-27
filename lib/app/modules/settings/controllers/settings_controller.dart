import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/app/data/services/theme_service.dart';

class SettingsController extends GetxController {
  late ThemeService _themeService;
  
  @override
  void onInit() {
    super.onInit();
    _themeService = Get.find<ThemeService>();
  }
  
  Color get currentColor => _themeService.primaryColor.value;
  
  Map<String, Color> get availableColors => ThemeService.themeColors;
  
  void setTheme(Color color) {
    _themeService.setThemeColor(color);
  }
  
  String getColorName(Color color) {
    return _themeService.getColorName(color);
  }
}
