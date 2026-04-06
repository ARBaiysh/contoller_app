import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';

class GpsConfirmationDialog extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double accuracy;
  final bool isUpdate;
  final VoidCallback onRetry;

  const GpsConfirmationDialog({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.isUpdate = false,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Иконка
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 40),
            ),

            const SizedBox(height: 20),

            Text(
              isUpdate ? 'Обновить координаты?' : 'Записать координаты?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              isUpdate ? 'Текущие координаты будут обновлены' : 'Будут записаны текущие GPS координаты',
              style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            // Блок точности
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getAccuracyBgColor(accuracy, isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getAccuracyBorderColor(accuracy), width: 1.5),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_getAccuracyIcon(accuracy), color: _getAccuracyColor(accuracy), size: 28),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Точность GPS',
                              style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600], fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text('\u00b1${accuracy.toStringAsFixed(1)} метров',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _getAccuracyColor(accuracy))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(_getAccuracyText(accuracy),
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : Colors.grey[600], fontWeight: FontWeight.w500)),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Координаты
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildCoordinateRow('Широта', latitude.toStringAsFixed(6), isDark),
                  const SizedBox(height: 10),
                  _buildCoordinateRow('Долгота', longitude.toStringAsFixed(6), isDark),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Кнопки
            Column(
              children: [
                // Повторить
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      onRetry();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accuracy <= 10 ? Colors.blue : Colors.orange,
                      side: BorderSide(color: accuracy <= 10 ? Colors.blue : Colors.orange, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.refresh, size: 20),
                    label: Text(
                      accuracy <= 10 ? 'Попробовать улучшить' : 'Попробовать ещё раз',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Отмена + Записать
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(result: false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.grey[300] : Colors.grey[700],
                          side: BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey[400]!, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Отмена', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.back(result: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text(isUpdate ? 'Обновить' : 'Записать',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoordinateRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600], fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'monospace', color: isDark ? Colors.white : Colors.black87)),
      ],
    );
  }

  Color _getAccuracyColor(double a) => a <= 10 ? Colors.green : a <= 30 ? Colors.orange : Colors.red;
  Color _getAccuracyBgColor(double a, bool d) => _getAccuracyColor(a).withValues(alpha: d ? 0.15 : 0.1);
  Color _getAccuracyBorderColor(double a) => _getAccuracyColor(a).withValues(alpha: 0.3);
  IconData _getAccuracyIcon(double a) => a <= 10 ? Icons.check_circle : a <= 30 ? Icons.warning : Icons.error;
  String _getAccuracyText(double a) => a <= 10 ? 'Отличная точность' : a <= 30 ? 'Хорошая точность' : 'Низкая точность';
}
