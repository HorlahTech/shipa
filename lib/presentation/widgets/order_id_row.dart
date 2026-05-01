import 'package:flutter/material.dart';
import 'package:shipa/core/theme/app_theme.dart';

class OrderIdRow extends StatelessWidget {
  final String orderId;
  final String status;

  const OrderIdRow({super.key, required this.orderId, required this.status});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order ID', style: AppTextStyles.orderIdLabel),
              const SizedBox(height: 4),
              Text(orderId, style: AppTextStyles.orderIdValue),
            ],
          ),
          _StatusBadge(status: status),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isDelivered = status.toLowerCase() == 'delivered';
    final badgeColor = isDelivered
        ? Colors.green.withOpacity(0.1)
        : AppColors.onDeliveryBadge;
    final contentColor = isDelivered ? Colors.green : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: contentColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: contentColor,
            ),
          ),
        ],
      ),
    );
  }
}
