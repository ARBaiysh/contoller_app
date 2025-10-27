/// Phone validation utility according to API requirements
/// Valid format: ^\\+?[0-9]{10,15}$ (10-15 digits, optional +)
class PhoneValidator {
  // Regex pattern matching backend validation
  static final RegExp _phonePattern = RegExp(r'^\+?[0-9]{10,15}$');

  /// Validates phone number according to API requirements
  /// Returns true if valid, false otherwise
  static bool isValid(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return false;
    }
    return _phonePattern.hasMatch(phone.trim());
  }

  /// Returns formatted phone number or null if invalid
  static String? format(String? phone) {
    if (phone == null) return null;
    final trimmed = phone.trim();
    if (!isValid(trimmed)) return null;
    return trimmed;
  }

  /// Returns error message if phone is invalid, null otherwise
  static String? getErrorMessage(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return 'Номер телефона не может быть пустым';
    }

    final trimmed = phone.trim();

    // Check if contains only digits and optional +
    if (!RegExp(r'^[\+0-9]+$').hasMatch(trimmed)) {
      return 'Номер должен содержать только цифры и символ +';
    }

    // Extract digits only
    final digitsOnly = trimmed.replaceAll('+', '');
    final digitCount = digitsOnly.length;

    if (digitCount < 10) {
      return 'Номер слишком короткий (минимум 10 цифр)';
    }

    if (digitCount > 15) {
      return 'Номер слишком длинный (максимум 15 цифр)';
    }

    if (!_phonePattern.hasMatch(trimmed)) {
      return 'Неверный формат номера';
    }

    // Additional validation: check for realistic phone number format
    // Require either + at start OR at least 11 digits (with country code)
    if (!trimmed.startsWith('+') && digitCount < 11) {
      return 'Укажите код страны (например: +996 или 996)';
    }

    // Check for repeating digits (like 7777777777)
    if (RegExp(r'^(\d)\1+$').hasMatch(digitsOnly)) {
      return 'Номер не может состоять из одинаковых цифр';
    }

    return null;
  }

  /// Cleans phone number from spaces, dashes, brackets
  /// Example: "+996 (700) 12-34-56" -> "+996700123456"
  static String clean(String phone) {
    return phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  /// Display phone in readable format
  /// Example: "+996700123456" -> "+996 700 12 34 56"
  static String display(String? phone) {
    if (phone == null || phone.isEmpty) return '';

    final cleaned = clean(phone);

    // Kyrgyzstan format: +996 XXX XX XX XX
    if (cleaned.startsWith('+996') && cleaned.length == 13) {
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 7)} ${cleaned.substring(7, 9)} ${cleaned.substring(9, 11)} ${cleaned.substring(11)}';
    }

    // Generic format: +XXX XXX XXX XXX
    if (cleaned.startsWith('+')) {
      final countryCode = cleaned.substring(0, 4);
      final rest = cleaned.substring(4);
      final parts = <String>[];
      for (var i = 0; i < rest.length; i += 3) {
        final end = (i + 3 > rest.length) ? rest.length : i + 3;
        parts.add(rest.substring(i, end));
      }
      return '$countryCode ${parts.join(' ')}';
    }

    return cleaned;
  }
}
