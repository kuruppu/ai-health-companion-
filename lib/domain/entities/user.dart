import 'package:equatable/equatable.dart';

class User extends Equatable {

  const User({
    required this.userId,
    required this.firebaseUid,
    required this.email,
    required this.displayName,
    required this.createdAt, required this.updatedAt, required this.isActive, this.photoUrl,
    this.age,
    this.heightCm,
    this.currentWeightKg,
    this.goalWeightKg,
    this.gender,
    this.emotionalGoal,
    this.activityLevel,
    this.dietaryPreferences,
    this.dailyCaloricTarget,
    this.proteinGrams,
    this.carbsGrams,
    this.fatsGrams,
    this.waterIntakeMl,
  });
  final String userId;
  final String firebaseUid;
  final String email;
  final String displayName;
  final String? photoUrl;

  // Physical attributes (optional during onboarding)
  final int? age;
  final double? heightCm;
  final double? currentWeightKg;
  final double? goalWeightKg;
  final String? gender;

  // Health goals
  final String? emotionalGoal;
  final String? activityLevel;
  final String? dietaryPreferences;

  // Calculated fields
  final double? dailyCaloricTarget;
  final double? proteinGrams;
  final double? carbsGrams;
  final double? fatsGrams;
  final double? waterIntakeMl;

  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  bool get hasCompletedProfile =>
      age != null &&
      heightCm != null &&
      currentWeightKg != null &&
      goalWeightKg != null &&
      emotionalGoal != null;

  bool get hasEmotionalGoal => emotionalGoal != null;

  User copyWith({
    String? userId,
    String? firebaseUid,
    String? email,
    String? displayName,
    String? photoUrl,
    int? age,
    double? heightCm,
    double? currentWeightKg,
    double? goalWeightKg,
    String? gender,
    String? emotionalGoal,
    String? activityLevel,
    String? dietaryPreferences,
    double? dailyCaloricTarget,
    double? proteinGrams,
    double? carbsGrams,
    double? fatsGrams,
    double? waterIntakeMl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) => User(
      userId: userId ?? this.userId,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      goalWeightKg: goalWeightKg ?? this.goalWeightKg,
      gender: gender ?? this.gender,
      emotionalGoal: emotionalGoal ?? this.emotionalGoal,
      activityLevel: activityLevel ?? this.activityLevel,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      dailyCaloricTarget: dailyCaloricTarget ?? this.dailyCaloricTarget,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      fatsGrams: fatsGrams ?? this.fatsGrams,
      waterIntakeMl: waterIntakeMl ?? this.waterIntakeMl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );

  @override
  List<Object?> get props => [
        userId,
        firebaseUid,
        email,
        displayName,
        photoUrl,
        age,
        heightCm,
        currentWeightKg,
        goalWeightKg,
        gender,
        emotionalGoal,
        activityLevel,
        dietaryPreferences,
        dailyCaloricTarget,
        proteinGrams,
        carbsGrams,
        fatsGrams,
        waterIntakeMl,
        createdAt,
        updatedAt,
        isActive,
      ];
}
