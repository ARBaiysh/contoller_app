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

                  // Username field
                  _buildUsernameField(context),
                  const SizedBox(height: Constants.paddingM),

                  // Password field
                  _buildPasswordField(context),
                  const SizedBox(height: Constants.paddingL),

                  // Login button
                  _buildLoginButton(context),
                  const SizedBox(height: Constants.paddingM),

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
            color: AppColors.primary.withOpacity(0.3),
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

  Widget _buildLoginButton(BuildContext context) {
    return Obx(() => ElevatedButton(
      onPressed: controller.isLoading ? null : controller.login,
      child: controller.isLoading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
          : const Text('Войти'),
    ));
  }

  Widget _buildCompanyInfo(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: Constants.paddingXL),
        Text(
          Constants.companyName,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Constants.paddingS),
        Text(
          'Версия ${Constants.appVersion}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.4),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}