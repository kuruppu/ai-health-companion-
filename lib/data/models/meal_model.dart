
import '../../domain/entities/meal.dart';

/// Data model for Meal entity
class MealModel extends Meal {
  const MealModel({
    required super.mealId,
    required super.userId,
    required super.mealType,
    required super.photoUrl,
    required super.analysis, required super.timestamp, required super.eatenAt, super.userNotes,
  });

  /// Create from entity
  factory MealModel.fromEntity(Meal meal) => MealModel(
      mealId: meal.mealId,
      userId: meal.userId,
      mealType: meal.mealType,
      photoUrl: meal.photoUrl,
      userNotes: meal.userNotes,
      analysis: meal.analysis,
      timestamp: meal.timestamp,
      eatenAt: meal.eatenAt,
    );

  /// Create from JSON (Firestore)
  factory MealModel.fromJson(Map<String, dynamic> json) => MealModel(
      mealId: json['meal_id'] as String,
      userId: json['user_id'] as String,
      mealType: MealType.values.byName(json['meal_type'] as String),
      photoUrl: json['photo_url'] as String,
      userNotes: json['user_notes'] as String?,
      analysis: MealAnalysisModel.fromJson(
        json['analysis'] as Map<String, dynamic>,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      eatenAt: DateTime.parse(json['eaten_at'] as String),
    );

  /// Create from Drift table row
  factory MealModel.fromDrift(Map<String, dynamic> row) => MealModel(
      mealId: row['meal_id'] as String,
      userId: row['user_id'] as String,
      mealType: MealType.values.byName(row['meal_type'] as String),
      photoUrl: row['photo_url'] as String,
      userNotes: row['user_notes'] as String?,
      analysis: MealAnalysisModel.fromJson(
        row['analysis'] as Map<String, dynamic>,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
      eatenAt: DateTime.fromMillisecondsSinceEpoch(row['eaten_at'] as int),
    );

  /// Alias for database compatibility (table uses loggedAt)
  DateTime get loggedAt => eatenAt;

  /// Convert to entity
  Meal toEntity() => Meal(
      mealId: mealId,
      userId: userId,
      mealType: mealType,
      photoUrl: photoUrl,
      userNotes: userNotes,
      analysis: analysis,
      timestamp: timestamp,
      eatenAt: eatenAt,
    );

  /// Convert to JSON (Firestore)
  Map<String, dynamic> toJson() => {
      'meal_id': mealId,
      'user_id': userId,
      'meal_type': mealType.name,
      'photo_url': photoUrl,
      'user_notes': userNotes,
      'analysis': MealAnalysisModel.fromEntity(analysis).toJson(),
      'timestamp': timestamp.toIso8601String(),
      'eaten_at': eatenAt.toIso8601String(),
    };

  /// Convert to Drift companion (for inserts/updates)
  Map<String, dynamic> toDrift() => {
      'meal_id': mealId,
      'user_id': userId,
      'meal_type': mealType.name,
      'photo_url': photoUrl,
      'user_notes': userNotes,
      'analysis': MealAnalysisModel.fromEntity(analysis).toJson(),
      'timestamp': timestamp.millisecondsSinceEpoch,
      'eaten_at': eatenAt.millisecondsSinceEpoch,
    };
}

/// Data model for MealAnalysis
class MealAnalysisModel extends MealAnalysis {
  const MealAnalysisModel({
    required super.description,
    required super.portionSize,
    required super.foodCategories,
    required super.healthScore,
    required super.feedback,
    super.suggestions,
    super.nutritionalEstimate,
  });

  /// Create from entity
  factory MealAnalysisModel.fromEntity(MealAnalysis analysis) => MealAnalysisModel(
      description: analysis.description,
      portionSize: analysis.portionSize,
      foodCategories: analysis.foodCategories,
      healthScore: analysis.healthScore,
      feedback: analysis.feedback,
      suggestions: analysis.suggestions,
      nutritionalEstimate: analysis.nutritionalEstimate != null
          ? NutritionalEstimateModel.fromEntity(analysis.nutritionalEstimate!)
          : null,
    );

  /// Create from JSON
  factory MealAnalysisModel.fromJson(Map<String, dynamic> json) => MealAnalysisModel(
      description: json['description'] as String,
      portionSize: PortionSize.values.byName(json['portion_size'] as String),
      foodCategories:
          (json['food_categories'] as List).map((e) => e as String).toList(),
      healthScore: json['health_score'] as int,
      feedback: json['feedback'] as String,
      suggestions: json['suggestions'] as String?,
      nutritionalEstimate: json['nutritional_estimate'] != null
          ? NutritionalEstimateModel.fromJson(
              json['nutritional_estimate'] as Map<String, dynamic>,
            )
          : null,
    );

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
      'description': description,
      'portion_size': portionSize.name,
      'food_categories': foodCategories,
      'health_score': healthScore,
      'feedback': feedback,
      'suggestions': suggestions,
      'nutritional_estimate': nutritionalEstimate != null
          ? NutritionalEstimateModel.fromEntity(nutritionalEstimate!).toJson()
          : null,
    };
}

/// Data model for NutritionalEstimate
class NutritionalEstimateModel extends NutritionalEstimate {
  const NutritionalEstimateModel({
    super.estimatedCalories,
    super.proteinLevel,
    super.carbLevel,
    super.fatLevel,
  });

  /// Create from entity
  factory NutritionalEstimateModel.fromEntity(NutritionalEstimate estimate) => NutritionalEstimateModel(
      estimatedCalories: estimate.estimatedCalories,
      proteinLevel: estimate.proteinLevel,
      carbLevel: estimate.carbLevel,
      fatLevel: estimate.fatLevel,
    );

  /// Create from JSON
  factory NutritionalEstimateModel.fromJson(Map<String, dynamic> json) => NutritionalEstimateModel(
      estimatedCalories: json['estimated_calories'] as int?,
      proteinLevel: json['protein_level'] as String?,
      carbLevel: json['carb_level'] as String?,
      fatLevel: json['fat_level'] as String?,
    );

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
      'estimated_calories': estimatedCalories,
      'protein_level': proteinLevel,
      'carb_level': carbLevel,
      'fat_level': fatLevel,
    };
}
