import 'package:flutter/material.dart';
import 'package:shipa/core/theme/app_theme.dart';
import 'package:shipa/domain/entities/delivery_entity.dart';
import 'package:shipa/presentation/widgets/courier_avatar.dart';

class CourierInfoCard extends StatelessWidget {
  final DeliveryEntity delivery;

  const CourierInfoCard({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          CourierAvatar(
            avatarUrl: delivery.courier.avatarUrl,
            name: delivery.courier.name,
            size: 56,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(delivery.courier.name, style: AppTextStyles.courierName),
                const SizedBox(height: 2),
                Text(delivery.courier.role, style: AppTextStyles.courierRole),
              ],
            ),
          ),
          _CallButton(phoneNumber: delivery.courier.phoneNumber),
        ],
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final String phoneNumber;

  const _CallButton({required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.phone_rounded,
                color: AppColors.primary,
                size: 14,
              ),
            ),
            const SizedBox(width: 8),
            Text('Call', style: AppTextStyles.callButton),
          ],
        ),
      ),
    );
  }
}
