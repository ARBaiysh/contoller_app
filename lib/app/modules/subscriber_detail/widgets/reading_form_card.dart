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
              decoration: const InputDecoration(
                labelText: 'Показание счетчика',
                hintText: 'Введите текущее показание',
                prefixIcon: Icon(Icons.speed),
              ),
            ),
            const SizedBox(height: Constants.paddingM),

            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isSubmitting
                    ? null
                    : () {
                  // Закрываем клавиатуру перед отправкой
                  FocusScope.of(context).unfocus();

                  if (controller.formKey.currentState!.validate()) {
                    controller.submitReading();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: Constants.paddingM),
                ),
                child: controller.isSubmitting
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: Constants.paddingS),
                    Text(controller.submissionMessage.isNotEmpty
                        ? controller.submissionMessage
                        : 'Отправка...'),
                  ],
                )
                    : const Text(
                  'Отправить показание',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}