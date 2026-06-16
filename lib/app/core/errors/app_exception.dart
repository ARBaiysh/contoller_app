/// Единое исключение приложения для ошибок сети/бэкенда.
///
/// Несёт человекочитаемое [message] (его показываем пользователю),
/// машиночитаемый [code] из бэкенда и [statusCode] HTTP-ответа.
///
/// `toString()` возвращает именно [message], чтобы существующий UI-код вида
/// `e.toString().replaceAll('Exception: ', '')` показывал нормальный текст.
class AppException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  AppException(this.message, {this.code, this.statusCode});

  @override
  String toString() => message;
}
