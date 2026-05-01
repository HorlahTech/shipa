import 'package:flutter/material.dart';

import 'package:shipa/core/theme/app_theme.dart';
import 'package:shipa/domain/entities/delivery_entity.dart';

class EtaBanner extends StatelessWidget {
  final int etaMinutes;
  final DeliveryStatus status;

  const EtaBanner({super.key, required this.etaMinutes, required this.status});

  @override
  Widget build(BuildContext context) {
    final isDelivered = status == DeliveryStatus.delivered;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              isDelivered
                  ? Icons.check_circle_rounded
                  : Icons.access_time_rounded,
              size: 20,
              color: isDelivered ? AppColors.primary : AppColors.textinfo,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.etaText,
                children: [
                  TextSpan(
                    text: isDelivered
                        ? 'Your package has been delivered successfully!'
                        : 'The package is estimated to arrive within the next ',
                  ),
                  if (!isDelivered)
                    TextSpan(
                      text: '$etaMinutes minutes',
                      style: AppTextStyles.etaText.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  if (!isDelivered) const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
