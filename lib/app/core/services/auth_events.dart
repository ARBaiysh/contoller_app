import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_pages.dart';

/// Координатор реакций на события авторизации (UI-слой).
///
/// Раньше редирект + снэкбар при истёкшей сессии жили прямо в Dio-интерцепторе
/// (слой данных). Теперь дата-слой только сообщает о событии, а вся UI-реакция —
/// здесь. Это убирает зависимость [ApiProvider] от Flutter/Get-навигации
/// и делает сетевой слой тестируемым.
class AuthEvents extends GetxService {
  bool _handling = false;

  /// Сессия истекла/отозвана — увести на экран входа и показать сообщение.
  void onSessionExpired() {
    if (_handling) return;
    _handling = true;

    Get.offAllNamed(Routes.AUTH);
    Get.snackbar(
      'Сессия истекла',
      'Войдите в систему заново',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  /// Сбросить флаг после успешного входа (чтобы снэкбар мог показаться снова).
  void reset() {
    _handling = false;
  }
}
