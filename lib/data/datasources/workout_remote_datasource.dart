import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/api_endpoints.dart';
import '../../domain/entities/workout.dart';
import '../models/workout_model.dart';

/// Remote data source for workout operations (Claude API + Firestore)
@injectable
class WorkoutRemoteDataSource {
  final Dio _dioClient;
  final FirebaseFirestore _firestore;
  final String _apiKey;

  const WorkoutRemoteDataSource(
    this._dioClient,
    this._firestore,
    @Named('claudeApiKey') this._apiKey,
  );

  /// Generate personalized workout using Claude AI
  ///
  /// Returns AI-generated workout
  Future<WorkoutModel> generateWorkout({
    required String userId,
    required String goalType,
    required int energyLevel,
    required int durationMinutes,
    required WorkoutDifficulty difficulty,
    List<String>? targetMuscles,
  }) async {
    try {
      // Fetch user profile for personalization
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();

      final requestBody = {
        'model': 'claude-3-sonnet-20240229',
        'max_tokens': 2048,
        'messages': [
          {
            'role': 'user',
            'content': _buildWorkoutPrompt(
              goalType: goalType,
              energyLevel: energyLevel,
              durationMinutes: durationMinutes,
              difficulty: difficulty,
              targetMuscles: targetMuscles,
              userData: userData,
            ),
          },
        ],
      };

      final response = await _dioClient.post(
        ApiEndpoints.claudeMessages,
        data: requestBody,
        options: Options(
          headers: {
            'x-api-key': _apiKey,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
          },
        ),
      );

      final content = response.data['content'][0]['text'] as String;
      return _parseWorkoutResponse(content, userId);
    } catch (e) {
      throw Exception('Failed to generate workout: $e');
    }
  }

  /// Save workout to Firestore
  Future<void> saveWorkoutToFirestore(WorkoutModel workout) async {
    try {
      await _firestore
          .collection('workouts')
          .doc(workout.workoutId)
          .set(workout.toJson());
    } catch (e) {
      throw Exception('Failed to save workout: $e');
    }
  }

  /// Fetch workouts from Firestore
  Future<List<WorkoutModel>> fetchWorkoutsFromFirestore({
    required String userId,
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('workouts')
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => WorkoutModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch workouts: $e');
    }
  }

  /// Delete workout from Firestore
  Future<void> deleteWorkoutFromFirestore(String workoutId) async {
    try {
      await _firestore.collection('workouts').doc(workoutId).delete();
    } catch (e) {
      throw Exception('Failed to delete workout: $e');
    }
  }

  /// Build Claude prompt for workout generation
  String _buildWorkoutPrompt({
    required String goalType,
    required int energyLevel,
    required int durationMinutes,
    required WorkoutDifficulty difficulty,
    List<String>? targetMuscles,
    Map<String, dynamic>? userData,
  }) {
    final emotionalGoal =
        userData?['emotional_goal'] as String? ?? 'feel healthier';
    final targetWeight = userData?['target_weight'] as num? ?? 55;

    final musclesFocus = targetMuscles != null && targetMuscles.isNotEmpty
        ? '\nFocus areas: ${targetMuscles.join(', ')}'
        : '';

    return '''Generate a personalized workout plan as an AI fitness coach.

User Context:
- Goal: $goalType (emotional goal: $emotionalGoal, target: ${targetWeight}kg)
- Current energy level: $energyLevel/5
- Desired duration: $durationMinutes minutes
- Difficulty: ${difficulty.displayName}$musclesFocus

Create a workout that:
1. Matches their current energy level (if low energy, focus on lower intensity)
2. Aligns with their goal type
3. Fits within the time constraint
4. Is appropriate for their difficulty level
5. Relates to their emotional goal of "$emotionalGoal"

Provide your workout in this EXACT JSON format:
{
  "name": "Workout name (motivating and descriptive)",
  "description": "Brief description relating to their goal (2-3 sentences)",
  "difficulty": "${difficulty.name}",
  "duration_minutes": $durationMinutes,
  "target_muscles": ["muscle1", "muscle2", ...],
  "exercises": [
    {
      "name": "Exercise name",
      "description": "How to perform this exercise",
      "type": "strength|cardio|flexibility|balance",
      "target_muscles": ["muscle1", "muscle2"],
      "sets": 3,
      "reps_per_set": 12,
      "duration_seconds": null,
      "rest_seconds": 60,
      "order_index": 0,
      "form_tips": ["tip1", "tip2"]
    }
  ],
  "ai_context": "Brief explanation of why this workout suits their current state"
}

Guidelines:
- For strength exercises: use "sets" and "reps_per_set"
- For cardio/hold exercises: use "duration_seconds" instead
- Order exercises logically (warm-up → main workout → cool-down)
- rest_seconds: 30-60 for cardio, 60-90 for strength
- Include 4-8 exercises depending on duration
- Be warm and encouraging in descriptions
- Relate workout benefits to their emotional goal

Return ONLY the JSON, no other text.''';
  }

  /// Parse Claude's JSON response into WorkoutModel
  WorkoutModel _parseWorkoutResponse(String jsonString, String userId) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      // Generate unique IDs
      final workoutId = DateTime.now().millisecondsSinceEpoch.toString();

      final exercises =
          (json['exercises'] as List).asMap().entries.map((entry) {
        final exerciseJson = entry.value as Map<String, dynamic>;
        return ExerciseModel.fromJson({
          ...exerciseJson,
          'exercise_id': '${workoutId}_ex_${entry.key}',
          'order_index': entry.key,
        });
      }).toList();

      return WorkoutModel(
        workoutId: workoutId,
        userId: userId,
        name: json['name'] as String,
        description: json['description'] as String,
        difficulty:
            WorkoutDifficulty.values.byName(json['difficulty'] as String),
        durationMinutes: json['duration_minutes'] as int,
        targetMuscles:
            (json['target_muscles'] as List).map((e) => e as String).toList(),
        exercises: exercises,
        isAiGenerated: true,
        aiContext: json['ai_context'] as String?,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to parse workout response: $e');
    }
  }
}
