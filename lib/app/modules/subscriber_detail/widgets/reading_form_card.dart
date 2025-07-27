import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';
import '../controllers/subscriber_detail_controller.dart';

class ReadingFormCard extends StatelessWidget {
  final SubscriberDetailController controller;

  const ReadingFormCard({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(Constants.paddingM),
      padding: const EdgeInsets.all(Constants.paddingM),
      decoration: Constants.getCardDecoration(context).copyWith(
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit,
                  color: AppColors.primary,
                ),
                const SizedBox(width: Constants.paddingS),
                Text(
                  'Новое показание',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Constants.paddingM),

            // Reading input
            TextFormField(
              controller: controller.readingController,
              validator: controller.validateReading,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: InputDecoration(
                labelText: 'Показание счетчика',
                hintText: 'Введите текущее показание',
                suffixText: 'кВт·ч',
                prefixIcon: Icon(Icons.speed),
              ),
            ),
            const SizedBox(height: Constants.paddingM),

            // Comment input
            TextFormField(
              controller: controller.commentController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Примечание (необязательно)',
                hintText: 'Дополнительная информация',
                prefixIcon: Icon(Icons.comment),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: Constants.paddingL),

            // Submit button
            Obx(() => ElevatedButton(
              onPressed: controller.isSubmitting ? null : controller.submitReading,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: controller.isSubmitting
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text('Отправить показание'),
            )),
          ],
        ),
      ),
    );
  }
}