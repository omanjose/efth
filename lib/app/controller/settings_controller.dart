import 'package:efth/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';



class SettingsController extends GetxController {
  final ThemeService themeService = Get.find<ThemeService>();

  void changeTheme(ThemeMode mode) {
    themeService.setThemeMode(mode);
  }

 

  String getThemeModeString() {
    switch (themeService.themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      default:
        return 'System';
    }
  }
}