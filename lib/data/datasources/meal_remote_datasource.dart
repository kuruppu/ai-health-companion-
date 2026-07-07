import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/api_endpoints.dart';
import '../../domain/entities/meal.dart';
import '../models/meal_model.dart';

/// Remote data source for meal operations (Claude API + Firestore)
@injectable
class MealRemoteDataSource {
  final Dio _dioClient;
  final FirebaseFirestore _firestore;
  final String _apiKey;

  const MealRemoteDataSource(
    this._dioClient,
    this._firestore,
    @Named('claudeApiKey') this._apiKey,
  );

  /// Analyze meal photo using Claude Vision API
  ///
  /// Returns AI-generated meal analysis
  Future<MealAnalysis> analyzeMealPhoto({
    required String userId,
    required String photoUrl,
    required MealType mealType,
    String? userNotes,
  }) async {
    try {
      // Fetch user profile for personalization
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();

      final requestBody = {
        'model': 'claude-3-sonnet-20240229',
        'max_tokens': 1024,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image',
                'source': {
                  'type': 'url',
                  'url': photoUrl,
                },
              },
              {
                'type': 'text',
                'text': _buildAnalysisPrompt(
                  mealType: mealType,
                  userNotes: userNotes,
                  userData: userData,
                ),
              },
            ],
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
      return _parseAnalysisResponse(content);
    } catch (e) {
      throw Exception('Failed to analyze meal: $e');
    }
  }

  /// Save meal to Firestore
  Future<void> saveMealToFirestore(MealModel meal) async {
    try {
      await _firestore.collection('meals').doc(meal.mealId).set(meal.toJson());
    } catch (e) {
      throw Exception('Failed to save meal: $e');
    }
  }

  /// Fetch meals from Firestore
  Future<List<MealModel>> fetchMealsFromFirestore({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) async {
    try {
      Query query = _firestore
          .collection('meals')
          .where('user_id', isEqualTo: userId)
          .orderBy('eaten_at', descending: true)
          .limit(limit);

      if (startDate != null) {
        query = query.where('eaten_at',
            isGreaterThanOrEqualTo: startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.where('eaten_at',
            isLessThanOrEqualTo: endDate.toIso8601String());
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => MealModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch meals: $e');
    }
  }

  /// Delete meal from Firestore
  Future<void> deleteMealFromFirestore(String mealId) async {
    try {
      await _firestore.collection('meals').doc(mealId).delete();
    } catch (e) {
      throw Exception('Failed to delete meal: $e');
    }
  }

  /// Build Claude prompt for meal analysis
  String _buildAnalysisPrompt({
    required MealType mealType,
    String? userNotes,
    Map<String, dynamic>? userData,
  }) {
    final emotionalGoal =
        userData?['emotional_goal'] as String? ?? 'feel healthier';
    final targetWeight = userData?['target_weight'] as num? ?? 55;

    return '''Analyze this ${mealType.displayName.toLowerCase()} photo as a supportive AI health coach.

${userNotes != null ? 'User context: $userNotes\n' : ''}
User's goal: $emotionalGoal (target: ${targetWeight}kg)

Provide your analysis in this EXACT JSON format:
{
  "description": "Brief description of what you see (2-3 sentences)",
  "portion_size": "small|medium|large",
  "food_categories": ["category1", "category2", ...],
  "health_score": 1-5,
  "feedback": "Warm, personalized feedback relating to their goal of '$emotionalGoal'. Focus on how this meal supports or could better support that goal. Be encouraging.",
  "suggestions": "Optional: 1-2 specific, actionable suggestions for next time (only if health_score < 4)",
  "nutritional_estimate": {
    "estimated_calories": approximate number or null,
    "protein_level": "low|moderate|high" or null,
    "carb_level": "low|moderate|high" or null,
    "fat_level": "low|moderate|high" or null
  }
}

Guidelines:
- Be warm and encouraging, not judgmental
- Focus on OUTCOMES (energy, feeling good) not just nutrition facts
- Relate feedback to their emotional goal
- health_score: 5=excellent, 4=good, 3=okay, 2=could improve, 1=not aligned with goals
- Keep description brief and positive
- Only include suggestions if genuinely helpful
- Nutritional estimate is optional and de-emphasized

Return ONLY the JSON, no other text.''';
  }

  /// Parse Claude's JSON response into MealAnalysis
  MealAnalysis _parseAnalysisResponse(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      return MealAnalysis(
        description: json['description'] as String,
        portionSize: PortionSize.values.byName(json['portion_size'] as String),
        foodCategories:
            (json['food_categories'] as List).map((e) => e as String).toList(),
        healthScore: json['health_score'] as int,
        feedback: json['feedback'] as String,
        suggestions: json['suggestions'] as String?,
        nutritionalEstimate: json['nutritional_estimate'] != null
            ? NutritionalEstimate(
                estimatedCalories:
                    json['nutritional_estimate']['estimated_calories'] as int?,
                proteinLevel:
                    json['nutritional_estimate']['protein_level'] as String?,
                carbLevel:
                    json['nutritional_estimate']['carb_level'] as String?,
                fatLevel: json['nutritional_estimate']['fat_level'] as String?,
              )
            : null,
      );
    } catch (e) {
      throw Exception('Failed to parse analysis response: $e');
    }
  }
}
