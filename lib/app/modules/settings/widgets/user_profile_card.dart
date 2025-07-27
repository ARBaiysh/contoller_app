import 'package:flutter/material.dart';
import '../controllers/settings_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/constants.dart';

class UserProfileCard extends StatelessWidget {
  final SettingsController controller;

  const UserProfileCard({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Constants.paddingL),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(Constants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // User avatar and basic info
          Row(
            children: [
              // Avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    controller.userName.isNotEmpty
                        ? controller.userName[0].toUpperCase()
                        : 'К',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Constants.paddingM),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.userRole,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Constants.paddingS,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Активен',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Constants.paddingM),

          // Assigned TPs info
          Container(
            padding: const EdgeInsets.all(Constants.paddingM),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Constants.borderRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.electrical_services,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: Constants.paddingS),
                    const Text(
                      'Закрепленные ТП:',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${controller.assignedTps.length} шт.',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (controller.assignedTps.length <= 3) ...[
                  const SizedBox(height: Constants.paddingS),
                  Wrap(
                    spacing: Constants.paddingS,
                    runSpacing: Constants.paddingXS,
                    children: controller.assignedTps.map((tpId) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Constants.paddingS,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'ТП-$tpId',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}