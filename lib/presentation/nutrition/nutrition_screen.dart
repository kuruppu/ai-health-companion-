import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/meal.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../providers/meal_provider.dart';
import 'widgets/meal_card.dart';
import 'widgets/photo_capture_button.dart';
import 'widgets/quick_log_sheet.dart';

class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});

  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen> {
  @override
  Widget build(BuildContext context) {
    final todaysMealsState = ref.watch(todaysMealsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutrition',
              style: AppTextStyles.body1Medium,
            ),
            Text(
              _getTodayDateString(),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // TODO: Show date picker for meal history
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(todaysMealsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: todaysMealsState.when(
        data: (meals) {
          if (meals.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(todaysMealsProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: meals.length + 1, // +1 for summary card
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildTodaySummary(meals);
                }

                final meal = meals[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: MealCard(meal: meal),
                );
              },
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                error.toString(),
                style: AppTextStyles.body1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () =>
                    ref.read(todaysMealsProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: PhotoCaptureButton(
        onPhotoSelected: (file) {
          _showQuickLogSheet(context, file);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No meals logged today',
              style: AppTextStyles.h5,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Tap the camera button to snap a photo of your meal. I\'ll analyze it and give you personalized feedback!',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.camera_alt,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Photo-First Logging',
                    style: AppTextStyles.body1Medium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No manual entry needed!',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySummary(List<Meal> meals) {
    final totalMeals = meals.length;
    final avgHealthScore = meals.isEmpty
        ? 0.0
        : meals.map((m) => m.analysis.healthScore).reduce((a, b) => a + b) /
            meals.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Summary',
              style: AppTextStyles.body1Medium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    icon: Icons.restaurant,
                    label: 'Meals',
                    value: totalMeals.toString(),
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryItem(
                    icon: Icons.favorite,
                    label: 'Health Score',
                    value: avgHealthScore.toStringAsFixed(1),
                    color: _getHealthScoreColor(avgHealthScore),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.h6.copyWith(color: color),
              ),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getHealthScoreColor(double score) {
    if (score >= 4.0) return AppColors.success;
    if (score >= 3.0) return AppColors.warning;
    return AppColors.error;
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    final weekday = _getWeekdayString(now.weekday);
    final month = _getMonthString(now.month);
    return '$weekday, $month ${now.day}';
  }

  String _getWeekdayString(int weekday) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return weekdays[weekday - 1];
  }

  String _getMonthString(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  void _showQuickLogSheet(BuildContext context, dynamic file) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickLogSheet(photoFile: file),
    );
  }
}
