import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Constants.paddingL),
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  _buildLogo(context),
                  const SizedBox(height: Constants.paddingXL * 2),

                  // Title
                  Text(
                    Constants.appName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Constants.paddingM),

                  // Subtitle
                  Text(
                    'Войдите в систему',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Constants.paddingXL),

                  // Biometric login button (if available)
                  Obx(() => controller.showBiometricOption
                      ? _buildBiometricButton(context)
                      : const SizedBox.shrink()),

                  _buildRegionSelector(context),
                  const SizedBox(height: Constants.paddingM),

                  // Divider (if biometric is available)
                  Obx(() => controller.showBiometricOption
                      ? _buildDivider(context)
                      : const SizedBox.shrink()),

                  // Username field
                  _buildUsernameField(context),
                  const SizedBox(height: Constants.paddingM),

                  // Password field
                  _buildPasswordField(context),
                  const SizedBox(height: Constants.paddingM),

                  // Remember me checkbox
                  _buildRememberMeCheckbox(context),
                  const SizedBox(height: Constants.paddingL),

                  // Login button
                  _buildLoginButton(context),
                  _buildSyncStatus(context),
                  const SizedBox(height: Constants.paddingM),

                  const SizedBox(height: Constants.paddingM),

// Sync status
                  Obx(() => controller.isSyncing
                      ? Column(
                    children: [
                      const LinearProgressIndicator(),
                      const SizedBox(height: Constants.paddingM),
                      Text(
                        controller.syncMessage,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                      : const SizedBox.shrink()),

                  // Company info
                  _buildCompanyInfo(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.electric_bolt,
          size: 60,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBiometricButton(BuildContext context) {
    return Column(
      children: [
        Obx(() => SizedBox(
          width: double.infinity,
          height: Constants.buttonHeight,
          child: OutlinedButton.icon(
            onPressed: controller.isBiometricLoading ? null : controller.loginWithBiometrics,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Constants.borderRadius),
              ),
            ),
            icon: controller.isBiometricLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.fingerprint, size: 24),
            label: FutureBuilder<String>(
              future: controller.getBiometricButtonText(),
              builder: (context, snapshot) {
                return Text(
                  controller.isBiometricLoading
                      ? 'Аутентификация...'
                      : 'Войти с помощью ${snapshot.data ?? 'биометрии'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ),
        )),
        const SizedBox(height: Constants.paddingL),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Theme.of(context).dividerColor)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Constants.paddingM),
              child: Text(
                'или',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                ),
              ),
            ),
            Expanded(child: Divider(color: Theme.of(context).dividerColor)),
          ],
        ),
        const SizedBox(height: Constants.paddingL),
      ],
    );
  }

  Widget _buildUsernameField(BuildContext context) {
    return TextFormField(
      controller: controller.usernameController,
      validator: controller.validateUsername,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: 'Логин',
        hintText: 'Введите ваш логин',
        prefixIcon: const Icon(Icons.person_outline),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return Obx(() => TextFormField(
      controller: controller.passwordController,
      validator: controller.validatePassword,
      obscureText: !controller.isPasswordVisible,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => controller.login(),
      decoration: InputDecoration(
        labelText: 'Пароль',
        hintText: 'Введите ваш пароль',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            controller.isPasswordVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: controller.togglePasswordVisibility,
        ),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
    ));
  }

  Widget _buildRememberMeCheckbox(BuildContext context) {
    return Obx(() => Row(
      children: [
        Checkbox(
          value: controller.rememberMe,
          onChanged: (_) => controller.toggleRememberMe(),
          activeColor: AppColors.primary,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => controller.toggleRememberMe(),
            child: Text(
              'Запомнить меня',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    ));
  }

  Widget _buildLoginButton(BuildContext context) {
    return Obx(() {
      final isButtonEnabled = controller.isFormValid && !controller.isSyncing;

      return ElevatedButton(
        onPressed: isButtonEnabled ? controller.login : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isButtonEnabled ? AppColors.primary : Colors.grey,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
          disabledForegroundColor: Colors.grey.withValues(alpha: 0.6),
          padding: const EdgeInsets.symmetric(vertical: Constants.paddingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Constants.borderRadius),
          ),
        ),
        child: SizedBox(
          height: 24,
          child: controller.isLoading || controller.isSyncing
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : Text(
            controller.isSyncing ? 'Синхронизация...' : 'Войти',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSyncStatus(BuildContext context) {
    return Obx(() {
      if (!controller.isSyncing) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(top: Constants.paddingM),
        child: Column(
          children: [
            Text(
              controller.syncMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: Constants.paddingXS),
            Text(
              'Пожалуйста, подождите...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCompanyInfo(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: Constants.paddingXL),
        Text(
          Constants.companyName,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Constants.paddingS),
        Text(
          'Версия ${Constants.appVersion}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.4),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegionSelector(BuildContext context) {
    return Obx(() => DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Регион',
        hintText: 'Выберите регион',
        prefixIcon: const Icon(Icons.location_on_outlined),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      ),
      value: controller.selectedRegion?.code,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Выберите регион';
        }
        return null;
      },
      items: controller.regions
          .map((region) => DropdownMenuItem(
        value: region.code,
        child: Text(region.name),
      ))
          .toList(),
      onChanged: controller.isLoading || controller.isSyncing
          ? null
          : (value) {
        final region = controller.regions
            .firstWhereOrNull((r) => r.code == value);
        controller.selectRegion(region);
      },
    ));
  }
}