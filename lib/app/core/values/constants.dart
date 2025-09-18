import 'package:flutter/material.dart';

class Constants {
  Constants._();

  // Storage keys (добавить если их нет)
  static const String usernameKey = 'username';
  static const String passwordKey = 'password';
  static const String regionCodeKey = 'region_code';

// API timeouts (новые)
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration syncTimeout = Duration(seconds: 60);
  static const Duration syncCheckInterval = Duration(seconds: 5);
  static const Duration maxSyncWaitTime = Duration(minutes: 5);
  // API Configuration
  static const bool useMockData = false;
  static const String biometricKey = 'biometric_enabled';


  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'is_dark_mode';
  static const String languageKey = 'app_language';

  // App Info
  static const String appName = 'ОшПЭС: Контролер';
  static const String appVersion = '1.0.0';
  static const String companyName = 'ОАО «ОшПЭС»';

  // Pagination
  static const int itemsPerPage = 20;
  static const int searchDebounceMs = 500;

  // UI Constants
  static const double borderRadius = 12.0;
  static const double cardElevation = 0.0;
  static const double buttonHeight = 52.0;
  static const double inputHeight = 56.0;
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  // Padding & Margins
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Font Sizes
  static const double fontSizeXS = 12.0;
  static const double fontSizeS = 14.0;
  static const double fontSizeM = 16.0;
  static const double fontSizeL = 18.0;
  static const double fontSizeXL = 20.0;
  static const double fontSizeXXL = 24.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Validation Rules
  static const int pinMinLength = 4;
  static const int pinMaxLength = 6;
  static const int accountNumberLength = 11;
  static const int minReadingValue = 0;
  static const int maxReadingValue = 999999;

  // Status Colors (добавляем для удобства из AppColors)
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Date Formats
  static const String dateFormat = 'dd.MM.yyyy';
  static const String dateTimeFormat = 'dd.MM.yyyy HH:mm';
  static const String timeFormat = 'HH:mm';

  // Error Messages
  static const String networkError = 'Ошибка сети. Проверьте подключение к интернету.';
  static const String serverError = 'Ошибка сервера. Попробуйте позже.';
  static const String unknownError = 'Произошла неизвестная ошибка.';
  static const String authError = 'Неверный логин или PIN-код.';
  static const String sessionExpired = 'Сессия истекла. Войдите снова.';

  // Success Messages
  static const String readingSubmitted = 'Показание успешно отправлено';
  static const String loginSuccess = 'Вход выполнен успешно';
  static const String dataUpdated = 'Данные обновлены';

  // Meter Types
  static const List<String> meterTypes = [
    'СОЭ',
    'СОЭ ЖК',
    'DD5',
    'DD5 ЖК',
    'Меркурий',
    'Меркурий ЖК',
    'НЕХ-12СУ',
  ];

  // Report Types
  static const Map<String, String> reportTypes = {
    'readings': 'Ведомость контрольного обхода',
    'disconnections': 'Ведомость отключений',
    'debtors': 'Список должников',
    'payments': 'Отчет по оплатам',
  };

  // Helper method for card decoration
  static BoxDecoration getCardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}