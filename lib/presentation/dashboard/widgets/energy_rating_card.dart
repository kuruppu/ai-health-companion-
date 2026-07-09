import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class EnergyRatingCard extends StatelessWidget {

  const EnergyRatingCard({
    required this.currentLevel,
    required this.message,
    required this.onRatingChanged,
    super.key,
  });
  final int? currentLevel;
  final String message;
  final Function(int) onRatingChanged;

  @override
  Widget build(BuildContext context) => Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getEnergyColor(currentLevel).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.bolt,
                    color: _getEnergyColor(currentLevel),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Today\'s Energy',
                        style: AppTextStyles.body1Medium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final level = index + 1;
                final isSelected = currentLevel == level;

                return GestureDetector(
                  onTap: () => onRatingChanged(level),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _getEnergyColor(level)
                          : Colors.grey.shade200,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? _getEnergyColor(level)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.bolt,
                        color: isSelected ? Colors.white : Colors.grey.shade400,
                        size: 28,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Low',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                Text(
                  'High',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

  Color _getEnergyColor(int? level) {
    if (level == null) return AppColors.primary;

    switch (level) {
      case 5:
        return AppColors.energy5;
      case 4:
        return AppColors.energy4;
      case 3:
        return AppColors.energy3;
      case 2:
        return AppColors.energy2;
      case 1:
        return AppColors.energy1;
      default:
        return AppColors.primary;
    }
  }
}
