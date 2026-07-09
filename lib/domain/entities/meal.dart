import 'package:equatable/equatable.dart';

/// Represents a meal logged by the user with AI analysis
class Meal extends Equatable {

  const Meal({
    required this.mealId,
    required this.userId,
    required this.mealType,
    required this.photoUrl,
    required this.analysis, required this.timestamp, required this.eatenAt, this.userNotes,
  });
  /// Unique identifier for the meal
  final String mealId;

  /// User who logged the meal
  final String userId;

  /// Type of meal (breakfast, lunch, dinner, snack)
  final MealType mealType;

  /// Photo URL (Firebase Storage)
  final String photoUrl;

  /// Optional user description/notes
  final String? userNotes;

  /// AI-generated analysis from Claude
  final MealAnalysis analysis;

  /// When the meal was logged
  final DateTime timestamp;

  /// When the meal was actually eaten (can differ from timestamp)
  final DateTime eatenAt;

  @override
  List<Object?> get props => [
        mealId,
        userId,
        mealType,
        photoUrl,
        userNotes,
        analysis,
        timestamp,
        eatenAt,
      ];

  Meal copyWith({
    String? mealId,
    String? userId,
    MealType? mealType,
    String? photoUrl,
    String? userNotes,
    MealAnalysis? analysis,
    DateTime? timestamp,
    DateTime? eatenAt,
  }) => Meal(
      mealId: mealId ?? this.mealId,
      userId: userId ?? this.userId,
      mealType: mealType ?? this.mealType,
      photoUrl: photoUrl ?? this.photoUrl,
      userNotes: userNotes ?? this.userNotes,
      analysis: analysis ?? this.analysis,
      timestamp: timestamp ?? this.timestamp,
      eatenAt: eatenAt ?? this.eatenAt,
    );
}

/// AI-generated analysis of the meal
class MealAnalysis extends Equatable {

  const MealAnalysis({
    required this.description,
    required this.portionSize,
    required this.foodCategories,
    required this.healthScore,
    required this.feedback,
    this.suggestions,
    this.nutritionalEstimate,
  });
  /// What Claude identified in the photo
  final String description;

  /// Estimated portion size (small, medium, large)
  final PortionSize portionSize;

  /// Main food categories present
  final List<String> foodCategories;

  /// Health score (1-5, where 5 is healthiest)
  final int healthScore;

  /// Personalized feedback based on user's goals
  final String feedback;

  /// Suggestions for improvement
  final String? suggestions;

  /// Estimated nutritional info (optional, not emphasized)
  final NutritionalEstimate? nutritionalEstimate;

  @override
  List<Object?> get props => [
        description,
        portionSize,
        foodCategories,
        healthScore,
        feedback,
        suggestions,
        nutritionalEstimate,
      ];
}

/// Nutritional estimate (de-emphasized, not the focus)
class NutritionalEstimate extends Equatable {

  const NutritionalEstimate({
    this.estimatedCalories,
    this.proteinLevel,
    this.carbLevel,
    this.fatLevel,
  });
  final int? estimatedCalories;
  final String? proteinLevel; // 'low', 'moderate', 'high'
  final String? carbLevel;
  final String? fatLevel;

  @override
  List<Object?> get props => [
        estimatedCalories,
        proteinLevel,
        carbLevel,
        fatLevel,
      ];
}

/// Meal type classification
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }
}

/// Portion size classification
enum PortionSize {
  small,
  medium,
  large;

  String get displayName {
    switch (this) {
      case PortionSize.small:
        return 'Small';
      case PortionSize.medium:
        return 'Medium';
      case PortionSize.large:
        return 'Large';
    }
  }
}
