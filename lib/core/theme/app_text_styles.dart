import 'package:flutter/material.dart';

import '../constants/asset_paths.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Headings (Poppins font family)
  static const TextStyle h1 = TextStyle(
    fontFamily: AssetPaths.fontFamilyPoppins,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: AssetPaths.fontFamilyPoppins,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: AssetPaths.fontFamilyPoppins,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: AssetPaths.fontFamilyPoppins,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle h5 = TextStyle(
    fontFamily: AssetPaths.fontFamilyPoppins,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle h6 = TextStyle(
    fontFamily: AssetPaths.fontFamilyPoppins,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // Body Text (Inter font family)
  static const TextStyle body1 = TextStyle(
    fontFamily: AssetPaths.fontFamilyInter,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: AssetPaths.fontFamilyInter,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle body1Medium = TextStyle(
    fontFamily: AssetPaths.fontFamilyInter,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle body2Medium = TextStyle(
    fontFamily: AssetPaths.fontFamilyInter,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  // Caption & Small Text
  static const TextStyle caption = TextStyle(
    fontFamily: AssetPaths.fontFamilyInter,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle captionMedium = TextStyle(
    fontFamily: AssetPaths.fontFamilyInter,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: AssetPaths.fontFamilyInter,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.6,
    letterSpacing: 1.5,
    color: AppColors.textSecondary,
  );

  // Button Text
  static const TextStyle button = TextStyle(
    fontFamily: AssetPaths.fontFamilyInter,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: AssetPaths.fontFamilyInter,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
  );

  // Feature-Specific Styles
  static const TextStyle chatMessage = TextStyle(
    fontFamily: AssetPaths.fontFamilyInter,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle chatTimestamp = TextStyle(
    fontFamily: AssetPaths.fontFamilyInter,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textTertiary,
  );

  static const TextStyle mealName = TextStyle(
    fontFamily: AssetPaths.fontFamilyPoppins,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle calories = TextStyle(
    fontFamily: AssetPaths.fontFamilyInter,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.primary,
  );

  static const TextStyle caloriesLarge = TextStyle(
    fontFamily: AssetPaths.fontFamilyInter,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.primary,
  );

  static const TextStyle workoutTitle = TextStyle(
    fontFamily: AssetPaths.fontFamilyPoppins,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle workoutDuration = TextStyle(
    fontFamily: AssetPaths.fontFamilyInter,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle dashboardMetric = TextStyle(
    fontFamily: AssetPaths.fontFamilyInter,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle dashboardLabel = TextStyle(
    fontFamily: AssetPaths.fontFamilyInter,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle energyRating = TextStyle(
    fontFamily: AssetPaths.fontFamilyPoppins,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle goalProgress = TextStyle(
    fontFamily: AssetPaths.fontFamilyInter,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.primary,
  );

  static const TextStyle emotionalGoal = TextStyle(
    fontFamily: AssetPaths.fontFamilyPoppins,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // Input Text
  static const TextStyle inputText = TextStyle(
    fontFamily: AssetPaths.fontFamilyInter,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle inputLabel = TextStyle(
    fontFamily: AssetPaths.fontFamilyInter,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle inputHint = TextStyle(
    fontFamily: AssetPaths.fontFamilyInter,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textTertiary,
  );

  static const TextStyle inputError = TextStyle(
    fontFamily: AssetPaths.fontFamilyInter,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.error,
  );

  // Link Text
  static const TextStyle link = TextStyle(
    fontFamily: AssetPaths.fontFamilyInter,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
  );

  static const TextStyle linkSmall = TextStyle(
    fontFamily: AssetPaths.fontFamilyInter,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
  );
}
