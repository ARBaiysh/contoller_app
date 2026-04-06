import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';

class GpsSuccessDialog extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double accuracy;
  final VoidCallback onShowOnMap;

  const GpsSuccessDialog({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
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
            // Анимированная иконка успеха
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 80,
                    height: 80,
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
                    child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 40),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            Text(
              'Координаты сохранены!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

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
                  _buildRow(icon: Icons.north, label: 'Широта', value: latitude.toStringAsFixed(6), isDark: isDark),
                  const SizedBox(height: 12),
                  _buildRow(icon: Icons.east, label: 'Долгота', value: longitude.toStringAsFixed(6), isDark: isDark),
                  const SizedBox(height: 12),
                  _buildRow(
                    icon: Icons.my_location,
                    label: 'Точность',
                    value: '${accuracy.toStringAsFixed(1)} м',
                    valueColor: _getAccuracyColor(accuracy),
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Кнопки
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
                label: const Text('Показать на карте', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12),
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
                child: const Text('Закрыть', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow({required IconData icon, required String label, required String value, required bool isDark, Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isDark ? Colors.grey[500] : Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey.shade600)),
              const SizedBox(height: 2),
              Text(value,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'monospace',
                      color: valueColor ?? (isDark ? Colors.white : Colors.black87))),
            ],
          ),
        ),
      ],
    );
  }

  Color _getAccuracyColor(double a) => a <= 10 ? Colors.green : a <= 30 ? Colors.orange : Colors.red;
}
