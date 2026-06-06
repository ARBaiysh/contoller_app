import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Один вариант сортировки: значение (ключ), подпись и иконка.
class SortOption {
  final String value;
  final String label;
  final IconData icon;

  const SortOption({
    required this.value,
    required this.label,
    required this.icon,
  });
}

/// Хранит выбранный пользователем порядок сортировки для списков и
/// делает его постоянным (GetStorage). Реактивный — подписки в UI
/// (например, подзаголовок в Настройках) обновляются автоматически.
class SortPrefsService extends GetxService {
  final GetStorage _box = GetStorage();

  static const String _tpKey = 'sort_tp';
  static const String _subscribersKey = 'sort_subscribers';

  static const String tpDefault = 'code';
  static const String subscribersDefault = 'default';

  // Каталог вариантов — единый источник для шторки и настроек.
  static const List<SortOption> tpOptions = [
    SortOption(value: 'code', label: 'По коду', icon: Icons.tag),
    SortOption(value: 'name', label: 'По названию', icon: Icons.sort_by_alpha),
    SortOption(
      value: 'abonent_count',
      label: 'По числу абонентов',
      icon: Icons.groups_outlined,
    ),
  ];

  static const List<SortOption> subscriberOptions = [
    SortOption(
      value: 'default',
      label: 'Сначала для обхода',
      icon: Icons.directions_walk,
    ),
    SortOption(value: 'name', label: 'По ФИО', icon: Icons.sort_by_alpha),
    SortOption(
      value: 'account',
      label: 'По лицевому счёту',
      icon: Icons.tag,
    ),
    SortOption(value: 'address', label: 'По адресу', icon: Icons.place_outlined),
    SortOption(
      value: 'debt',
      label: 'По задолженности',
      icon: Icons.account_balance_wallet_outlined,
    ),
  ];

  // Реактивные значения текущего выбора.
  late final RxString tpSort;
  late final RxString subscribersSort;

  @override
  void onInit() {
    super.onInit();
    tpSort = (_box.read(_tpKey) as String? ?? tpDefault).obs;
    subscribersSort =
        (_box.read(_subscribersKey) as String? ?? subscribersDefault).obs;
  }

  void setTpSort(String value) {
    tpSort.value = value;
    _box.write(_tpKey, value);
  }

  void setSubscribersSort(String value) {
    subscribersSort.value = value;
    _box.write(_subscribersKey, value);
  }

  /// Подпись текущего варианта — для подзаголовков в настройках.
  String labelFor(List<SortOption> options, String value) {
    return options
        .firstWhere(
          (o) => o.value == value,
          orElse: () => options.first,
        )
        .label;
  }
}
