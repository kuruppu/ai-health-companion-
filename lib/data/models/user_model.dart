import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.userId,
    required super.firebaseUid,
    required super.email,
    required super.displayName,
    super.photoUrl,
    super.age,
    super.heightCm,
    super.currentWeightKg,
    super.goalWeightKg,
    super.gender,
    super.emotionalGoal,
    super.activityLevel,
    super.dietaryPreferences,
    super.dailyCaloricTarget,
    super.proteinGrams,
    super.carbsGrams,
    super.fatsGrams,
    super.waterIntakeMl,
    required super.createdAt,
    required super.updatedAt,
    required super.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as String,
      firebaseUid: json['firebaseUid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      age: json['age'] as int?,
      heightCm: json['heightCm'] as double?,
      currentWeightKg: json['currentWeightKg'] as double?,
      goalWeightKg: json['goalWeightKg'] as double?,
      gender: json['gender'] as String?,
      emotionalGoal: json['emotionalGoal'] as String?,
      activityLevel: json['activityLevel'] as String?,
      dietaryPreferences: json['dietaryPreferences'] as String?,
      dailyCaloricTarget: json['dailyCaloricTarget'] as double?,
      proteinGrams: json['proteinGrams'] as double?,
      carbsGrams: json['carbsGrams'] as double?,
      fatsGrams: json['fatsGrams'] as double?,
      waterIntakeMl: json['waterIntakeMl'] as double?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firebaseUid': firebaseUid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'age': age,
      'heightCm': heightCm,
      'currentWeightKg': currentWeightKg,
      'goalWeightKg': goalWeightKg,
      'gender': gender,
      'emotionalGoal': emotionalGoal,
      'activityLevel': activityLevel,
      'dietaryPreferences': dietaryPreferences,
      'dailyCaloricTarget': dailyCaloricTarget,
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatsGrams': fatsGrams,
      'waterIntakeMl': waterIntakeMl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      userId: user.userId,
      firebaseUid: user.firebaseUid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      age: user.age,
      heightCm: user.heightCm,
      currentWeightKg: user.currentWeightKg,
      goalWeightKg: user.goalWeightKg,
      gender: user.gender,
      emotionalGoal: user.emotionalGoal,
      activityLevel: user.activityLevel,
      dietaryPreferences: user.dietaryPreferences,
      dailyCaloricTarget: user.dailyCaloricTarget,
      proteinGrams: user.proteinGrams,
      carbsGrams: user.carbsGrams,
      fatsGrams: user.fatsGrams,
      waterIntakeMl: user.waterIntakeMl,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      isActive: user.isActive,
    );
  }

  User toEntity() {
    return User(
      userId: userId,
      firebaseUid: firebaseUid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      age: age,
      heightCm: heightCm,
      currentWeightKg: currentWeightKg,
      goalWeightKg: goalWeightKg,
      gender: gender,
      emotionalGoal: emotionalGoal,
      activityLevel: activityLevel,
      dietaryPreferences: dietaryPreferences,
      dailyCaloricTarget: dailyCaloricTarget,
      proteinGrams: proteinGrams,
      carbsGrams: carbsGrams,
      fatsGrams: fatsGrams,
      waterIntakeMl: waterIntakeMl,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
    );
  }
}
