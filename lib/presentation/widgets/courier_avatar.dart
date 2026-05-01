import 'package:flutter/material.dart';
import 'package:shipa/core/theme/app_theme.dart';

class CourierAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final double size;

  const CourierAvatar({
    super.key,
    this.avatarUrl,
    required this.name,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.divider, width: 2),
        color: AppColors.background,
      ),
      child: ClipOval(
        child: avatarUrl != null
            ? Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _initials(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _initials() {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: size * 0.35,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFE8E0D8),
      child: const Center(
        child: Icon(Icons.person, color: Color(0xFF9E8E7E), size: 32),
      ),
    );
  }
}
