import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';
import '../../../data/models/subscriber_model.dart';

class QrPaymentPage extends StatefulWidget {
  final SubscriberModel subscriber;

  static const String qrData =
      'https://app.mbank.kg/qr/#00020101021132440012c2c.mbank.kg01020210129967702204061302125204999953034175909BAIYSh%20A.6304e422';

  const QrPaymentPage({
    super.key,
    required this.subscriber,
  });

  @override
  State<QrPaymentPage> createState() => _QrPaymentPageState();
}

class _QrPaymentPageState extends State<QrPaymentPage> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isSharing = false;

  Future<File?> _captureImage() async {
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/qr_payment_${widget.subscriber.accountNumber}.png');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      print('[QR] Error capturing image: $e');
      return null;
    }
  }

  Future<void> _share() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      final file = await _captureImage();
      if (file == null) {
        Get.snackbar('Ошибка', 'Не удалось создать изображение',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red);
        return;
      }

      final hasDebt = widget.subscriber.balance > 0;
      final balanceText = hasDebt
          ? 'Задолженность: ${widget.subscriber.balance.toStringAsFixed(2)} сом'
          : 'Нет задолженности';

      final dateTime = DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'ОшПЭС - QR для оплаты\n'
            '$dateTime\n'
            '${widget.subscriber.fullName}\n'
            'Л/С: ${widget.subscriber.accountNumber}\n'
            'Адрес: ${widget.subscriber.address}\n'
            '$balanceText',
      );
    } finally {
      setState(() => _isSharing = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasDebt = widget.subscriber.balance > 0;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('QR для оплаты'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Constants.paddingM),
        child: Column(
          children: [
            // Карточка с QR — захватываемая область
            RepaintBoundary(
              key: _repaintKey,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Дата и время
                    Text(
                      DateFormat('dd.MM.yyyy  HH:mm').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Имя
                    Text(
                      widget.subscriber.fullName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Л/С: ${widget.subscriber.accountNumber}',
                      style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),

                    const SizedBox(height: 16),

                    // QR-код с лого ОшПЭС в центре
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          QrImageView(
                            data: QrPaymentPage.qrData,
                            version: QrVersions.auto,
                            size: 280,
                            gapless: true,
                            errorCorrectionLevel: QrErrorCorrectLevel.H,
                            errorStateBuilder: (ctx, err) {
                              return const SizedBox(
                                width: 280,
                                height: 280,
                                child: Center(child: Text('Ошибка генерации QR')),
                              );
                            },
                          ),
                          // Лого в центре QR
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              'ОшПЭС',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Сумма
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: hasDebt
                            ? Colors.red.withValues(alpha: isDark ? 0.15 : 0.08)
                            : AppColors.success.withValues(alpha: isDark ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: hasDebt
                              ? Colors.red.withValues(alpha: 0.2)
                              : AppColors.success.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            hasDebt ? 'Задолженность' : 'Баланс',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasDebt
                                ? '${widget.subscriber.balance.toStringAsFixed(2)} сом'
                                : 'Нет задолженности',
                            style: TextStyle(
                              fontSize: hasDebt ? 26 : 16,
                              fontWeight: FontWeight.bold,
                              color: hasDebt ? Colors.red : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Кнопка Поделиться
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSharing ? null : _share,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: _isSharing
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.share_outlined, size: 20),
                label: const Text('Поделиться',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
