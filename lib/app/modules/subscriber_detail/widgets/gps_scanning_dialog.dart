import 'package:flutter/material.dart';

class GpsScanningDialog extends StatelessWidget {
  final int currentAttempt;
  final int maxAttempts;
  final double? bestAccuracy;

  const GpsScanningDialog({
    super.key,
    required this.currentAttempt,
    required this.maxAttempts,
    this.bestAccuracy,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = currentAttempt / maxAttempts;
    final percentage = (progress * 100).toInt();

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Пульсирующая иконка GPS
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.2),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 80,
                      height: 80,
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
                      child: const Icon(Icons.gps_fixed, color: Colors.white, size: 40),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              Text(
                'Определение координат',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'Замер $currentAttempt из $maxAttempts',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Держите устройство неподвижно...',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Прогресс бар
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Прогресс',
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600], fontWeight: FontWeight.w500)),
                      Text('$percentage%',
                          style: TextStyle(fontSize: 12, color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                    ),
                  ),
                ],
              ),

              if (bestAccuracy != null) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getAccuracyBgColor(bestAccuracy!, isDark),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _getAccuracyBorderColor(bestAccuracy!), width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_getAccuracyIcon(bestAccuracy!), color: _getAccuracyColor(bestAccuracy!), size: 20),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Лучшая точность',
                              style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                          Text('\u00b1${bestAccuracy!.toStringAsFixed(1)} м',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _getAccuracyColor(bestAccuracy!))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 14, color: isDark ? Colors.grey[500] : Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text('Выполняется серия замеров',
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : Colors.grey[500], fontStyle: FontStyle.italic)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAccuracyColor(double a) => a <= 10 ? Colors.green : a <= 30 ? Colors.orange : Colors.red;
  Color _getAccuracyBgColor(double a, bool d) => _getAccuracyColor(a).withValues(alpha: d ? 0.15 : 0.1);
  Color _getAccuracyBorderColor(double a) => _getAccuracyColor(a).withValues(alpha: 0.3);
  IconData _getAccuracyIcon(double a) => a <= 10 ? Icons.check_circle : a <= 30 ? Icons.warning : Icons.error;
}
