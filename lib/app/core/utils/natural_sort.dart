/// Натуральное (человеческое) сравнение строк: числовые фрагменты сравниваются
/// как числа, а не посимвольно. Благодаря этому "2" < "10" < "100", а коды
/// вида "ТП-2" / "ТП-10" располагаются в ожидаемом порядке.
///
/// Учитывает:
///  - ведущие нули ("007" == "7" по величине, но более короткая запись считается
///    меньшей при равенстве значения — стабильный порядок);
///  - сколь угодно длинные числа (сравнение по длине + лексикографически, без
///    переполнения int);
///  - регистр букв (без учёта регистра).
int naturalCompare(String a, String b) {
  final ia = _tokenize(a);
  final ib = _tokenize(b);

  final len = ia.length < ib.length ? ia.length : ib.length;
  for (var i = 0; i < len; i++) {
    final ta = ia[i];
    final tb = ib[i];

    if (ta.isNumber && tb.isNumber) {
      final cmp = _compareNumeric(ta.value, tb.value);
      if (cmp != 0) return cmp;
    } else {
      final cmp = ta.value.toLowerCase().compareTo(tb.value.toLowerCase());
      if (cmp != 0) return cmp;
    }
  }

  // Все общие токены равны — короче идёт первым.
  return ia.length.compareTo(ib.length);
}

/// Сравнение двух числовых фрагментов, заданных строками (без перевода в int).
int _compareNumeric(String a, String b) {
  final na = _stripLeadingZeros(a);
  final nb = _stripLeadingZeros(b);

  if (na.length != nb.length) return na.length.compareTo(nb.length);
  final cmp = na.compareTo(nb);
  if (cmp != 0) return cmp;

  // Значения равны — большее число ведущих нулей считаем "меньшим",
  // чтобы порядок был детерминированным ("07" перед "7").
  return b.length.compareTo(a.length);
}

String _stripLeadingZeros(String s) {
  var i = 0;
  while (i < s.length - 1 && s[i] == '0') {
    i++;
  }
  return s.substring(i);
}

List<_Token> _tokenize(String s) {
  final tokens = <_Token>[];
  if (s.isEmpty) return tokens;

  final buffer = StringBuffer();
  bool? bufferIsDigit;

  void flush() {
    if (buffer.isNotEmpty) {
      tokens.add(_Token(buffer.toString(), bufferIsDigit ?? false));
      buffer.clear();
    }
  }

  for (final rune in s.runes) {
    final ch = String.fromCharCode(rune);
    final isDigit = rune >= 0x30 && rune <= 0x39; // '0'..'9'
    if (bufferIsDigit == null || isDigit == bufferIsDigit) {
      buffer.write(ch);
      bufferIsDigit = isDigit;
    } else {
      flush();
      buffer.write(ch);
      bufferIsDigit = isDigit;
    }
  }
  flush();
  return tokens;
}

class _Token {
  final String value;
  final bool isNumber;
  const _Token(this.value, this.isNumber);
}
