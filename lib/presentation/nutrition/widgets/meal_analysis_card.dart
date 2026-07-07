import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/meal.dart';

class MealAnalysisCard extends StatelessWidget {
  final Meal meal;

  const MealAnalysisCard({
    required this.meal,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: _getHealthScoreColor(
                                meal.analysis.healthScore,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                meal.analysis.healthScore.toString(),
                                style: AppTextStyles.h4.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getHealthScoreLabel(
                                    meal.analysis.healthScore,
                                  ),
                                  style: AppTextStyles.h6,
                                ),
                                Text(
                                  meal.mealType.displayName,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Description
                      _buildSection(
                        title: 'What I See',
                        icon: Icons.visibility,
                        content: Text(
                          meal.analysis.description,
                          style: AppTextStyles.body1,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Feedback
                      _buildSection(
                        title: 'Personalized Feedback',
                        icon: Icons.favorite,
                        content: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            meal.analysis.feedback,
                            style: AppTextStyles.body1,
                          ),
                        ),
                      ),

                      // Suggestions (if any)
                      if (meal.analysis.suggestions != null &&
                          meal.analysis.suggestions!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildSection(
                          title: 'Suggestions for Next Time',
                          icon: Icons.lightbulb,
                          content: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.warning.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              meal.analysis.suggestions!,
                              style: AppTextStyles.body1,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Meal details
                      _buildSection(
                        title: 'Meal Details',
                        icon: Icons.info_outline,
                        content: Column(
                          children: [
                            _buildDetailRow(
                              'Portion Size',
                              meal.analysis.portionSize.displayName,
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              'Food Categories',
                              meal.analysis.foodCategories.join(', '),
                            ),
                          ],
                        ),
                      ),

                      // Nutritional estimate (de-emphasized)
                      if (meal.analysis.nutritionalEstimate != null) ...[
                        const SizedBox(height: 20),
                        _buildSection(
                          title: 'Nutritional Estimate',
                          icon: Icons.analytics,
                          content: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                if (meal.analysis.nutritionalEstimate!
                                        .estimatedCalories !=
                                    null)
                                  _buildDetailRow(
                                    'Est. Calories',
                                    '~${meal.analysis.nutritionalEstimate!.estimatedCalories} cal',
                                  ),
                                if (meal.analysis.nutritionalEstimate!
                                        .proteinLevel !=
                                    null) ...[
                                  const SizedBox(height: 8),
                                  _buildDetailRow(
                                    'Protein',
                                    meal.analysis.nutritionalEstimate!
                                        .proteinLevel!,
                                  ),
                                ],
                                if (meal.analysis.nutritionalEstimate!
                                        .carbLevel !=
                                    null) ...[
                                  const SizedBox(height: 8),
                                  _buildDetailRow(
                                    'Carbs',
                                    meal.analysis.nutritionalEstimate!
                                        .carbLevel!,
                                  ),
                                ],
                                if (meal.analysis.nutritionalEstimate!
                                        .fatLevel !=
                                    null) ...[
                                  const SizedBox(height: 8),
                                  _buildDetailRow(
                                    'Fat',
                                    meal.analysis.nutritionalEstimate!.fatLevel!,
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Text(
                                  '* Estimates only, not the focus',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Close button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.body1Medium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.body1Medium,
        ),
      ],
    );
  }

  Color _getHealthScoreColor(int score) {
    if (score >= 4) return AppColors.success;
    if (score >= 3) return AppColors.warning;
    return AppColors.error;
  }

  String _getHealthScoreLabel(int score) {
    if (score >= 4) return 'Excellent Choice!';
    if (score >= 3) return 'Good Choice';
    if (score >= 2) return 'Could Be Better';
    return 'Needs Improvement';
  }
}
