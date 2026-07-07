import 'dart:convert';

import '../../domain/entities/progress_log.dart';

class ProgressLogModel extends ProgressLog {
  const ProgressLogModel({
    required super.logId,
    required super.userId,
    super.weightKg,
    super.bodyFatPercentage,
    super.waistCm,
    super.hipsCm,
    super.energyLevel,
    super.sleepQuality,
    super.moodRating,
    super.stressLevel,
    super.functionalMilestones,
    super.photoUrl,
    super.notes,
    super.aiInsights,
    required super.loggedAt,
    required super.createdAt,
  });

  factory ProgressLogModel.fromJson(Map<String, dynamic> json) {
    return ProgressLogModel(
      logId: json['logId'] as String,
      userId: json['userId'] as String,
      weightKg: json['weightKg'] as double?,
      bodyFatPercentage: json['bodyFatPercentage'] as double?,
      waistCm: json['waistCm'] as double?,
      hipsCm: json['hipsCm'] as double?,
      energyLevel: json['energyLevel'] as int?,
      sleepQuality: json['sleepQuality'] as int?,
      moodRating: json['moodRating'] as int?,
      stressLevel: json['stressLevel'] as int?,
      functionalMilestones: json['functionalMilestones'] != null
          ? List<String>.from(json['functionalMilestones'] as List)
          : null,
      photoUrl: json['photoUrl'] as String?,
      notes: json['notes'] as String?,
      aiInsights: json['aiInsights'] as String?,
      loggedAt: DateTime.parse(json['loggedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logId': logId,
      'userId': userId,
      'weightKg': weightKg,
      'bodyFatPercentage': bodyFatPercentage,
      'waistCm': waistCm,
      'hipsCm': hipsCm,
      'energyLevel': energyLevel,
      'sleepQuality': sleepQuality,
      'moodRating': moodRating,
      'stressLevel': stressLevel,
      'functionalMilestones': functionalMilestones,
      'photoUrl': photoUrl,
      'notes': notes,
      'aiInsights': aiInsights,
      'loggedAt': loggedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProgressLogModel.fromEntity(ProgressLog log) {
    return ProgressLogModel(
      logId: log.logId,
      userId: log.userId,
      weightKg: log.weightKg,
      bodyFatPercentage: log.bodyFatPercentage,
      waistCm: log.waistCm,
      hipsCm: log.hipsCm,
      energyLevel: log.energyLevel,
      sleepQuality: log.sleepQuality,
      moodRating: log.moodRating,
      stressLevel: log.stressLevel,
      functionalMilestones: log.functionalMilestones,
      photoUrl: log.photoUrl,
      notes: log.notes,
      aiInsights: log.aiInsights,
      loggedAt: log.loggedAt,
      createdAt: log.createdAt,
    );
  }

  ProgressLog toEntity() {
    return ProgressLog(
      logId: logId,
      userId: userId,
      weightKg: weightKg,
      bodyFatPercentage: bodyFatPercentage,
      waistCm: waistCm,
      hipsCm: hipsCm,
      energyLevel: energyLevel,
      sleepQuality: sleepQuality,
      moodRating: moodRating,
      stressLevel: stressLevel,
      functionalMilestones: functionalMilestones,
      photoUrl: photoUrl,
      notes: notes,
      aiInsights: aiInsights,
      loggedAt: loggedAt,
      createdAt: createdAt,
    );
  }
}
