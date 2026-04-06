import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';

class GpsCurrentDialog extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final VoidCallback onUpdate;
  final VoidCallback onShowOnMap;

  const GpsCurrentDialog({
    super.key,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.onUpdate,
    required this.onShowOnMap,
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
                  colors: [Colors.green.shade400, Colors.green.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 40),
            ),

            const SizedBox(height: 20),

            Text(
              'Координаты объекта',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              'Координаты записаны',
              style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Координаты
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey.shade200, width: 1),
              ),
              child: Column(
                children: [
                  _buildRow(
                    icon: Icons.north,
                    label: 'Широта',
                    value: latitude.toStringAsFixed(6),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildRow(
                    icon: Icons.east,
                    label: 'Долгота',
                    value: longitude.toStringAsFixed(6),
                    isDark: isDark,
                  ),
                  if (accuracy != null) ...[
                    const SizedBox(height: 12),
                    _buildRow(
                      icon: Icons.my_location,
                      label: 'Точность',
                      value: '\u00b1${accuracy!.round()} м',
                      valueColor: _getAccuracyColor(accuracy!),
                      isDark: isDark,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Кнопка "Показать на карте"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  onShowOnMap();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.map, size: 20),
                label: const Text('Показать на карте',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),

            const SizedBox(height: 12),

            // Кнопка "Обновить координаты"
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.back();
                  onUpdate();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.gps_fixed, size: 20),
                label: const Text('Обновить координаты',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),

            const SizedBox(height: 12),

            // Кнопка "Закрыть"
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.grey[300] : Colors.grey[700],
                  side: BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey[400]!, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Закрыть',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isDark ? Colors.grey[500] : Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey.shade600)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                    color: valueColor ?? (isDark ? Colors.white : Colors.black87),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Color _getAccuracyColor(double a) => a <= 10 ? Colors.green : a <= 30 ? Colors.orange : Colors.red;
}
