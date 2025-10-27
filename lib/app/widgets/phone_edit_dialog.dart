import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/phone_validator.dart';

/// Диалог редактирования телефона абонента
class PhoneEditDialog extends StatefulWidget {
  final String? currentPhone;
  final String accountNumber;
  final Function(String phoneNumber) onSave;
  final VoidCallback? onDelete;

  const PhoneEditDialog({
    super.key,
    required this.currentPhone,
    required this.accountNumber,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<PhoneEditDialog> createState() => _PhoneEditDialogState();
}

class _PhoneEditDialogState extends State<PhoneEditDialog> {
  late TextEditingController _phoneController;
  String? _errorText;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Если есть текущий номер, убираем +996 для отображения
    String initialValue = '';
    if (widget.currentPhone != null && widget.currentPhone!.isNotEmpty) {
      final cleaned = PhoneValidator.clean(widget.currentPhone!);
      // Убираем +996 или 996 в начале
      if (cleaned.startsWith('+996')) {
        initialValue = cleaned.substring(4); // Убираем +996
      } else if (cleaned.startsWith('996')) {
        initialValue = cleaned.substring(3); // Убираем 996
      } else if (cleaned.startsWith('+')) {
        initialValue = cleaned.substring(1); // Убираем только +
      } else {
        initialValue = cleaned;
      }
    }
    _phoneController = TextEditingController(text: initialValue);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _validateAndSave() {
    setState(() {
      _errorText = null;
    });

    final input = _phoneController.text.trim();

    if (input.isEmpty) {
      setState(() {
        _errorText = 'Введите номер телефона';
      });
      return;
    }

    // Очищаем от пробелов, скобок, дефисов
    final cleaned = input.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Проверяем, что только цифры
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      setState(() {
        _errorText = 'Номер должен содержать только цифры';
      });
      return;
    }

    // Проверяем длину (должно быть ровно 9 цифр для киргизского номера)
    if (cleaned.length != 9) {
      setState(() {
        _errorText = 'Введите 9 цифр (код оператора + номер)';
      });
      return;
    }

    // Проверка на повторяющиеся цифры
    if (RegExp(r'^(\d)\1+$').hasMatch(cleaned)) {
      setState(() {
        _errorText = 'Номер не может состоять из одинаковых цифр';
      });
      return;
    }

    // Формируем полный номер с +996
    final fullPhone = '+996$cleaned';

    setState(() {
      _isSaving = true;
    });

    try {
      widget.onSave(fullPhone);
      Get.back();
    } catch (e) {
      setState(() {
        _isSaving = false;
        _errorText = 'Ошибка сохранения';
      });
    }
  }

  void _confirmDelete() {
    Get.dialog(
      AlertDialog(
        title: const Text('Удалить телефон?'),
        content: const Text(
          'После удаления будет использоваться номер из базы 1С (если есть).',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Закрываем диалог подтверждения
              widget.onDelete?.call();
              Get.back(); // Закрываем диалог редактирования
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final hasCurrentPhone = widget.currentPhone != null && widget.currentPhone!.isNotEmpty;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasCurrentPhone ? 'Изменить номер' : 'Добавить номер',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Л/С ${widget.accountNumber}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: _isSaving ? null : () => Get.back(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: colorScheme.onSurface.withOpacity(0.6),
                        size: 22,
                      ),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                      splashRadius: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Контент
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Поле ввода номера
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? colorScheme.surfaceVariant.withOpacity(0.3)
                          : colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: _errorText != null
                          ? Border.all(color: colorScheme.error, width: 2)
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Префикс +996
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 4),
                          child: Text(
                            '+996',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface.withOpacity(0.4),
                              fontSize: 20,
                            ),
                          ),
                        ),

                        // Поле ввода
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              hintText: '700 123 456',
                              hintStyle: theme.textTheme.headlineSmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.25),
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 18,
                              ),
                            ),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                              letterSpacing: 1,
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(9),
                            ],
                            enabled: !_isSaving,
                            autofocus: true,
                            onChanged: (value) {
                              setState(() {
                                _errorText = null;
                              });
                            },
                            onSubmitted: (_) => _validateAndSave(),
                          ),
                        ),

                        // Счетчик символов
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Text(
                            '${_phoneController.text.length}/9',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.4),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Сообщение об ошибке
                  if (_errorText != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 18,
                            color: colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorText!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.error,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Подсказка
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 16,
                        color: colorScheme.onSurface.withOpacity(0.4),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Введите 9 цифр (пример: 700123456)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.5),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Кнопки действий
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  // Кнопка сохранения
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _validateAndSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              hasCurrentPhone ? 'Обновить' : 'Добавить',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Вторая строка кнопок
                  Row(
                    children: [
                      // Кнопка отмены
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: TextButton(
                            onPressed: _isSaving ? null : () => Get.back(),
                            style: TextButton.styleFrom(
                              foregroundColor: colorScheme.onSurface.withOpacity(0.6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Отмена',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Кнопка удаления (если есть текущий телефон)
                      if (hasCurrentPhone && widget.onDelete != null) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: TextButton(
                              onPressed: _isSaving ? null : _confirmDelete,
                              style: TextButton.styleFrom(
                                foregroundColor: colorScheme.error,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.delete_outline_rounded, size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    'Удалить',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
