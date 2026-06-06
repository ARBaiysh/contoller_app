import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Единые читаемые снекбары: сплошной насыщенный фон + белый текст/иконка.
/// Контраст одинаково хороший на светлой и тёмной теме (не зависит от темы).
class AppSnackbar {
  AppSnackbar._();

  static const _green = Color(0xFF2E7D32);
  static const _red = Color(0xFFC62828);
  static const _blue = Color(0xFF1565C0);
  static const _orange = Color(0xFFEF6C00);

  static void success(String title, String message, {Duration? duration}) =>
      _show(title, message, _green, Icons.check_circle_outline, duration);

  static void error(String title, String message, {Duration? duration}) =>
      _show(title, message, _red, Icons.error_outline, duration);

  static void info(String title, String message, {Duration? duration}) =>
      _show(title, message, _blue, Icons.info_outline, duration);

  static void warning(String title, String message, {Duration? duration}) =>
      _show(title, message, _orange, Icons.warning_amber_outlined, duration);

  static void _show(
    String title,
    String message,
    Color bg,
    IconData icon,
    Duration? duration,
  ) {
    // Закрываем предыдущий, чтобы не наслаивались
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: bg,
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: duration ?? const Duration(seconds: 3),
      maxWidth: 600,
    );
  }
}
