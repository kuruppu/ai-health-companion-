import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF6366F1); // Indigo 500
  static const Color primaryDark = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryLight = Color(0xFFA5B4FC); // Indigo 300

  // Secondary Colors
  static const Color secondary = Color(0xFF10B981); // Emerald 500
  static const Color secondaryDark = Color(0xFF059669); // Emerald 600
  static const Color secondaryLight = Color(0xFF6EE7B7); // Emerald 300

  // Accent Colors
  static const Color accent = Color(0xFFF59E0B); // Amber 500
  static const Color accentDark = Color(0xFFD97706); // Amber 600
  static const Color accentLight = Color(0xFFFBBF24); // Amber 400

  // Background Colors
  static const Color backgroundLight = Color(0xFFF9FAFB); // Gray 50
  static const Color backgroundDark = Color(0xFF111827); // Gray 900
  static const Color surfaceLight = Color(0xFFFFFFFF); // White
  static const Color surfaceDark = Color(0xFF1F2937); // Gray 800

  // Text Colors
  static const Color textPrimary = Color(0xFF111827); // Gray 900
  static const Color textSecondary = Color(0xFF6B7280); // Gray 500
  static const Color textTertiary = Color(0xFF9CA3AF); // Gray 400
  static const Color textDisabled = Color(0xFFD1D5DB); // Gray 300

  // Semantic Colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color info = Color(0xFF3B82F6); // Blue 500

  // Feature-Specific Colors
  static const Color nutrition = Color(0xFFEC4899); // Pink 500
  static const Color workout = Color(0xFF8B5CF6); // Violet 500
  static const Color sleep = Color(0xFF6366F1); // Indigo 500
  static const Color hydration = Color(0xFF06B6D4); // Cyan 500
  static const Color weight = Color(0xFF10B981); // Emerald 500
  static const Color energy = Color(0xFFF59E0B); // Amber 500

  // Chart Colors
  static const Color chartPrimary = Color(0xFF6366F1); // Indigo 500
  static const Color chartSecondary = Color(0xFF10B981); // Emerald 500
  static const Color chartTertiary = Color(0xFFF59E0B); // Amber 500
  static const Color chartQuaternary = Color(0xFFEC4899); // Pink 500

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF6366F1), // Indigo 500
    Color(0xFF8B5CF6), // Violet 500
  ];

  static const List<Color> successGradient = [
    Color(0xFF10B981), // Emerald 500
    Color(0xFF06B6D4), // Cyan 500
  ];

  static const List<Color> warningGradient = [
    Color(0xFFF59E0B), // Amber 500
    Color(0xFFEF4444), // Red 500
  ];

  // Neutral Colors
  static const Color divider = Color(0xFFE5E7EB); // Gray 200
  static const Color border = Color(0xFFD1D5DB); // Gray 300
  static const Color shadow = Color(0x1A000000); // Black 10%

  // Overlay Colors
  static const Color overlay = Color(0x80000000); // Black 50%
  static const Color overlayLight = Color(0x40000000); // Black 25%

  // Energy Rating Colors (for outcome-focused dashboard)
  static const Color energy1 = Color(0xFFEF4444); // Red 500 - Very Low
  static const Color energy2 = Color(0xFFF59E0B); // Amber 500 - Low
  static const Color energy3 = Color(0xFFFBBF24); // Amber 400 - Moderate
  static const Color energy4 = Color(0xFF10B981); // Emerald 500 - Good
  static const Color energy5 = Color(0xFF059669); // Emerald 600 - Excellent

  // Progress Colors
  static const Color progressBackground = Color(0xFFE5E7EB); // Gray 200
  static const Color progressFill = Color(0xFF6366F1); // Indigo 500

  // Meal Type Colors
  static const Color breakfast = Color(0xFFFBBF24); // Amber 400
  static const Color lunch = Color(0xFF10B981); // Emerald 500
  static const Color dinner = Color(0xFF6366F1); // Indigo 500
  static const Color snack = Color(0xFFEC4899); // Pink 500

  // Workout Intensity Colors
  static const Color lowIntensity = Color(0xFF10B981); // Emerald 500
  static const Color mediumIntensity = Color(0xFFF59E0B); // Amber 500
  static const Color highIntensity = Color(0xFFEF4444); // Red 500

  // Calendar Colors
  static const Color today = Color(0xFF6366F1); // Indigo 500
  static const Color selected = Color(0xFF4F46E5); // Indigo 600
  static const Color event = Color(0xFF10B981); // Emerald 500
}
