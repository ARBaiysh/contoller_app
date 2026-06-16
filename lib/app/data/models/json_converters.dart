/// Безопасный разбор даты: возвращает null вместо исключения на пустом/битом значении
/// (сохраняет прежнюю семантику DateTime.tryParse в ручных fromJson).
DateTime? dateTimeOrNull(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
