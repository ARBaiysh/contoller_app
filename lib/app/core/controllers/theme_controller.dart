import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    _loadTheme();
  }

  @override
  void onReady() {
    super.onReady();
    // Применяем тему после полной инициализации
    _applyTheme();
  }

  // Загрузка сохраненной темы
  void _loadTheme() {
    final savedTheme = _box.read(_key);
    if (savedTheme != null) {
      _isDarkMode.value = savedTheme;
    } else {
      // Если нет сохраненной темы, используем системную
      _isDarkMode.value = _getSystemTheme();
      _saveTheme(); // Сохраняем первоначальное значение
    }
  }

  // Получение системной темы
  bool _getSystemTheme() {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }

  // Применение темы
  void _applyTheme() {
    Get.changeThemeMode(theme);
    _updateStatusBar();
  }

  // Toggle theme
  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    _saveTheme();
    _applyTheme();
  }

  // Set specific theme
  void setTheme(bool isDark) {
    if (_isDarkMode.value != isDark) {
      _isDarkMode.value = isDark;
      _saveTheme();
      _applyTheme();
    }
  }

  // Следование системной теме
  void followSystemTheme() {
    final systemTheme = _getSystemTheme();
    setTheme(systemTheme);
  }

  // Save theme preference
  void _saveTheme() {
    _box.write(_key, _isDarkMode.value);
  }

  // Update status bar icons color
  void _updateStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _isDarkMode.value
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: _isDarkMode.value
            ? Brightness.dark
            : Brightness.light,
        systemNavigationBarColor: _isDarkMode.value
            ? const Color(0xFF0D1117)
            : const Color(0xFFF5F5F5),
        systemNavigationBarIconBrightness: _isDarkMode.value
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }

  // Check if current theme is dark
  bool get isCurrentThemeDark => Get.isDarkMode;

  // Get current theme colors
  Color get primaryColor => Get.theme.primaryColor;
  Color get backgroundColor => Get.theme.scaffoldBackgroundColor;
  Color get cardColor => Get.theme.cardColor;

  // Get text colors based on theme
  Color get textPrimaryColor =>
      _isDarkMode.value ? const Color(0xFFE0E0E0) : const Color(0xFF212121);

  Color get textSecondaryColor =>
      _isDarkMode.value ? const Color(0xFF9E9E9E) : const Color(0xFF757575);

  // Debug методы
  void debugPrintThemeState() {
    print('=== THEME DEBUG ===');
    print('isDarkMode: ${_isDarkMode.value}');
    print('Get.isDarkMode: ${Get.isDarkMode}');
    print('Current ThemeMode: ${Get.theme.brightness}');
    print('Saved in storage: ${_box.read(_key)}');
    print('==================');
  }
}