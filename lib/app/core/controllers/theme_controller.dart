import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  final _box = GetStorage();
  final _key = 'isDarkMode';

  // Observable theme mode
  final _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;

  ThemeMode get theme => _isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    // Load saved theme preference
    _isDarkMode.value = _box.read(_key) ?? false;

    // Listen to system theme changes
    ever(_isDarkMode, (_) => _saveTheme());
  }

  // Toggle theme
  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    Get.changeThemeMode(theme);

    // Update status bar
    _updateStatusBar();
  }

  // Set specific theme
  void setTheme(bool isDark) {
    _isDarkMode.value = isDark;
    Get.changeThemeMode(theme);
    _updateStatusBar();
  }

  // Save theme preference
  void _saveTheme() {
    _box.write(_key, _isDarkMode.value);
  }

  // Update status bar icons color
  void _updateStatusBar() {
    // This will be called automatically by the theme
    // but we can force update if needed
    Get.forceAppUpdate();
  }

  // Check if current theme is dark
  bool get isCurrentThemeDark => Get.isDarkMode;

  // Get current theme colors
  Color get primaryColor => Get.theme.primaryColor;
  Color get backgroundColor => Get.theme.scaffoldBackgroundColor;
  Color get cardColor => Get.theme.cardColor;

  // Get text colors based on theme
  Color get textPrimaryColor =>
      Get.isDarkMode ? const Color(0xFFE0E0E0) : const Color(0xFF212121);

  Color get textSecondaryColor =>
      Get.isDarkMode ? const Color(0xFF9E9E9E) : const Color(0xFF757575);
}