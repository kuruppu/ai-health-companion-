import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Quick response buttons for meal check-ins
class QuickResponseButtons extends StatelessWidget {

  const QuickResponseButtons({
    required this.onResponse,
    required this.hasPendingCheckIn,
    super.key,
  });
  final Function(String) onResponse;
  final bool hasPendingCheckIn;

  @override
  Widget build(BuildContext context) {
    if (!hasPendingCheckIn) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(
          top: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick responses:',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickButton(
                context,
                'Yes, I ate',
                Icons.check_circle_outline,
                AppColors.success,
              ),
              _buildQuickButton(
                context,
                'Not yet',
                Icons.schedule,
                AppColors.warning,
              ),
              _buildQuickButton(
                context,
                'Skip today',
                Icons.block,
                AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
  ) => InkWell(
      onTap: () => onResponse(label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
}
