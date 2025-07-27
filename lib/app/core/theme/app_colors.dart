import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF42A5F5);

  // Secondary Colors
  static const Color secondary = Color(0xFF424242);
  static const Color secondaryDark = Color(0xFF212121);
  static const Color secondaryLight = Color(0xFF616161);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF0D1117); // Темный с легким синим оттенком

  // Card Colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF161B22); // Карточки с синеватым оттенком

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFF9E9E9E);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Input Colors
  static const Color inputFillLight = Color(0xFFF0F0F0);
  static const Color inputFillDark = Color(0xFF2C2C2C);

  // Divider Colors
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF373737);

  // Status Badge Colors
  static const Color statusAvailable = Color(0xFF4CAF50);
  static const Color statusProcessing = Color(0xFFFFC107);
  static const Color statusCompleted = Color(0xFF9E9E9E);

  // Chart Colors
  static const Color chartBlue = Color(0xFF2196F3);
  static const Color chartGreen = Color(0xFF4CAF50);
  static const Color chartOrange = Color(0xFFFF9800);
  static const Color chartRed = Color(0xFFF44336);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1976D2),
      Color(0xFF1565C0),
    ],
  );
}