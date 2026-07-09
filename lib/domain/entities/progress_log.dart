import 'package:equatable/equatable.dart';

class ProgressLog extends Equatable {

  const ProgressLog({
    required this.logId,
    required this.userId,
    required this.loggedAt, required this.createdAt, this.weightKg,
    this.bodyFatPercentage,
    this.waistCm,
    this.hipsCm,
    this.energyLevel,
    this.sleepQuality,
    this.moodRating,
    this.stressLevel,
    this.functionalMilestones,
    this.photoUrl,
    this.notes,
    this.aiInsights,
  });
  final String logId;
  final String userId;

  // Physical metrics (optional)
  final double? weightKg;
  final double? bodyFatPercentage;
  final double? waistCm;
  final double? hipsCm;

  // Outcome-focused metrics (primary)
  final int? energyLevel; // 1-5 stars
  final int? sleepQuality; // 1-5 stars
  final int? moodRating; // 1-5 stars
  final int? stressLevel; // 1-5 stars

  // Functional milestones
  final List<String>? functionalMilestones;

  // Photos
  final String? photoUrl;

  // Notes
  final String? notes;
  final String? aiInsights;

  // Timestamps
  final DateTime loggedAt;
  final DateTime createdAt;

  ProgressLog copyWith({
    String? logId,
    String? userId,
    double? weightKg,
    double? bodyFatPercentage,
    double? waistCm,
    double? hipsCm,
    int? energyLevel,
    int? sleepQuality,
    int? moodRating,
    int? stressLevel,
    List<String>? functionalMilestones,
    String? photoUrl,
    String? notes,
    String? aiInsights,
    DateTime? loggedAt,
    DateTime? createdAt,
  }) => ProgressLog(
      logId: logId ?? this.logId,
      userId: userId ?? this.userId,
      weightKg: weightKg ?? this.weightKg,
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
      waistCm: waistCm ?? this.waistCm,
      hipsCm: hipsCm ?? this.hipsCm,
      energyLevel: energyLevel ?? this.energyLevel,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      moodRating: moodRating ?? this.moodRating,
      stressLevel: stressLevel ?? this.stressLevel,
      functionalMilestones: functionalMilestones ?? this.functionalMilestones,
      photoUrl: photoUrl ?? this.photoUrl,
      notes: notes ?? this.notes,
      aiInsights: aiInsights ?? this.aiInsights,
      loggedAt: loggedAt ?? this.loggedAt,
      createdAt: createdAt ?? this.createdAt,
    );

  @override
  List<Object?> get props => [
        logId,
        userId,
        weightKg,
        bodyFatPercentage,
        waistCm,
        hipsCm,
        energyLevel,
        sleepQuality,
        moodRating,
        stressLevel,
        functionalMilestones,
        photoUrl,
        notes,
        aiInsights,
        loggedAt,
        createdAt,
      ];
}
