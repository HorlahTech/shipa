import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shipa/core/constants/image_assets.dart';
import 'package:shipa/core/theme/app_theme.dart';
import 'package:shipa/domain/entities/delivery_entity.dart';

class DeliveryStatusTimeline extends StatelessWidget {
  final DeliveryEntity delivery;

  const DeliveryStatusTimeline({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    final isDelivered = delivery.status == DeliveryStatus.delivered;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: [
          _TimelineItem(
            isActive: !isDelivered,
            icon: ImageAssets.dotIcon,
            iconColor: !isDelivered ? AppColors.primary : AppColors.textLight,
            label: 'On Delivery',
            description: isDelivered
                ? 'Package was delivered to destination'
                : 'Courier is delivering the package ${delivery.etaMinutes} minutes destination',
            time: TimeOfDay.now().format(context),
            date: DateFormat('d MMM, y').format(DateTime.now()),
            showConnector: true,
          ),
          _TimelineItem(
            isActive: isDelivered,
            icon: ImageAssets.mapinIcon,
            iconColor: isDelivered ? AppColors.primary : AppColors.textLight,
            label: 'Delivered',
            description: delivery.destinationAddress,
            time: isDelivered ? TimeOfDay.now().format(context) : null,
            date: isDelivered
                ? DateFormat('d MMM, y').format(DateTime.now())
                : null,
            showConnector: false,
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final bool isActive;
  final String icon;
  final Color iconColor;
  final String label;
  final String description;
  final String? time;
  final String? date;
  final bool showConnector;

  const _TimelineItem({
    required this.isActive,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.description,
    this.time,
    this.date,
    required this.showConnector,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                SvgPicture.asset(icon),
                if (showConnector)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: AppColors.divider,
                            width: 1.5,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.statusLabel),
                  const SizedBox(height: 2),
                  Text(description, style: AppTextStyles.statusValue),
                ],
              ),
            ),
          ),

          if (time != null && date != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time!, style: AppTextStyles.timeText),
                const SizedBox(height: 2),
                Text(date!, style: AppTextStyles.dateText),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '----------',
                  style: AppTextStyles.timeText.copyWith(letterSpacing: 1),
                ),
                const SizedBox(height: 2),
                Text(
                  '---------',
                  style: AppTextStyles.timeText.copyWith(letterSpacing: 1),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
