import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';
import '../../../widgets/custom_app_bar.dart';
import '../controllers/meter_detail_controller.dart';

class MeterDetailView extends GetView<MeterDetailController> {
  const MeterDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Данные счётчика',
        actions: [
          Obx(() {
            if (controller.isLoading) {
              return Container(
                margin: const EdgeInsets.only(right: 12),
                width: 20,
                height: 20,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }
            return IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: controller.refresh,
              tooltip: 'Обновить',
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Загрузка данных счётчика...'),
                ],
              ),
            );
          }

          if (controller.hasError) {
            return _buildErrorState(context);
          }

          final data = controller.meterData;
          if (data == null) {
            return _buildErrorState(context);
          }

          return RefreshIndicator(
            onRefresh: controller.refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(Constants.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Основная информация о счётчике
                  _buildMainInfoCard(context, data),
                  const SizedBox(height: Constants.paddingM),

                  // Технические характеристики
                  _buildTechnicalCard(context, data),
                  const SizedBox(height: Constants.paddingM),

                  // Пломбы
                  _buildSealsCard(context, data),
                  const SizedBox(height: Constants.paddingXL),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMainInfoCard(BuildContext context, data) {
    return Container(
      padding: const EdgeInsets.all(Constants.paddingM),
      decoration: Constants.getCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.electric_meter,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: Constants.paddingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Прибор учёта',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.meterType,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Constants.paddingM),
          const Divider(),
          const SizedBox(height: Constants.paddingS),
          _InfoRow(label: 'Номер ПУ', value: data.meterNumber),
          _InfoRow(label: 'Дата установки', value: data.formattedMeterDate),
        ],
      ),
    );
  }

  Widget _buildTechnicalCard(BuildContext context, data) {
    return Container(
      padding: const EdgeInsets.all(Constants.paddingM),
      decoration: Constants.getCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                color: AppColors.info,
              ),
              const SizedBox(width: Constants.paddingS),
              Text(
                'Технические характеристики',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: Constants.paddingM),
          _InfoRow(label: 'Фазность', value: data.phaseDescription),
          _InfoRow(label: 'Ампераж', value: data.amperage),
          _InfoRow(label: 'Коэффициент', value: '${data.coefficient}'),
          _InfoRow(label: 'Значность', value: '${data.digitCapacity}'),
        ],
      ),
    );
  }

  Widget _buildSealsCard(BuildContext context, data) {
    return Container(
      padding: const EdgeInsets.all(Constants.paddingM),
      decoration: Constants.getCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_user,
                color: AppColors.success,
              ),
              const SizedBox(width: Constants.paddingS),
              Text(
                'Пломбы',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: Constants.paddingM),
          _SealRow(
            label: 'Госпломба',
            value: data.stateSeal,
            isValid: data.isSealValid(data.stateSeal),
          ),
          _SealRow(
            label: 'Одноразовая пломба',
            value: data.oneTimeSeal,
            isValid: data.isSealValid(data.oneTimeSeal),
          ),
          _SealRow(
            label: 'Пломба на крышке',
            value: data.coverSeal,
            isValid: data.isSealValid(data.coverSeal),
          ),
          _SealRow(
            label: 'Пломба на ящике',
            value: data.boxSeal,
            isValid: data.isSealValid(data.boxSeal),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Constants.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: Constants.paddingL),
            Text(
              'Не удалось загрузить данные',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Constants.paddingS),
            Obx(() => Text(
                  controller.errorMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                  textAlign: TextAlign.center,
                )),
            const SizedBox(height: Constants.paddingL),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Назад'),
                ),
                const SizedBox(width: Constants.paddingM),
                ElevatedButton.icon(
                  onPressed: controller.refresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Повторить'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Не указано' : value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SealRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isValid;

  const _SealRow({
    Key? key,
    required this.label,
    required this.value,
    required this.isValid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Icon(
                  isValid ? Icons.check_circle : Icons.cancel,
                  size: 18,
                  color: isValid ? AppColors.success : AppColors.warning,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    value.isEmpty ? 'Не указано' : value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
