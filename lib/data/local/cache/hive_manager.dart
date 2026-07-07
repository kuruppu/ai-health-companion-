import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/exceptions.dart';

@lazySingleton
class HiveManager {
  Box? _authBox;
  Box? _userBox;
  Box? _chatBox;
  Box? _nutritionBox;
  Box? _workoutBox;
  Box? _settingsBox;

  Future<void> init() async {
    try {
      await Hive.initFlutter();

      _authBox = await Hive.openBox(AppConstants.authBoxName);
      _userBox = await Hive.openBox(AppConstants.userBoxName);
      _chatBox = await Hive.openBox(AppConstants.chatBoxName);
      _nutritionBox = await Hive.openBox(AppConstants.nutritionBoxName);
      _workoutBox = await Hive.openBox(AppConstants.workoutBoxName);
      _settingsBox = await Hive.openBox(AppConstants.settingsBoxName);
    } catch (e) {
      throw CacheException(
        message: 'Failed to initialize Hive: ${e.toString()}',
      );
    }
  }

  // Auth Box Methods
  Future<void> saveAuthToken(String token) async {
    try {
      await _authBox?.put('auth_token', token);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save auth token: ${e.toString()}',
      );
    }
  }

  String? getAuthToken() {
    try {
      return _authBox?.get('auth_token') as String?;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get auth token: ${e.toString()}',
      );
    }
  }

  Future<void> deleteAuthToken() async {
    try {
      await _authBox?.delete('auth_token');
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete auth token: ${e.toString()}',
      );
    }
  }

  Future<void> saveRefreshToken(String token) async {
    try {
      await _authBox?.put('refresh_token', token);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save refresh token: ${e.toString()}',
      );
    }
  }

  String? getRefreshToken() {
    try {
      return _authBox?.get('refresh_token') as String?;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get refresh token: ${e.toString()}',
      );
    }
  }

  // User Box Methods
  Future<void> cacheUserData(Map<String, dynamic> userData) async {
    try {
      await _userBox?.put('user_data', userData);
    } catch (e) {
      throw CacheException(
        message: 'Failed to cache user data: ${e.toString()}',
      );
    }
  }

  Map<String, dynamic>? getCachedUserData() {
    try {
      final data = _userBox?.get('user_data');
      return data != null ? Map<String, dynamic>.from(data as Map) : null;
    } catch (e) {
      throw CacheException(
        message: 'Failed to get cached user data: ${e.toString()}',
      );
    }
  }

  Future<void> clearUserData() async {
    try {
      await _userBox?.delete('user_data');
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear user data: ${e.toString()}',
      );
    }
  }

  // Chat Box Methods
  Future<void> cacheChatHistory(List<Map<String, dynamic>> messages) async {
    try {
      await _chatBox?.put('chat_history', messages);
    } catch (e) {
      throw CacheException(
        message: 'Failed to cache chat history: ${e.toString()}',
      );
    }
  }

  List<Map<String, dynamic>>? getCachedChatHistory() {
    try {
      final data = _chatBox?.get('chat_history');
      if (data == null) return null;
      return (data as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (e) {
      throw CacheException(
        message: 'Failed to get cached chat history: ${e.toString()}',
      );
    }
  }

  Future<void> clearChatHistory() async {
    try {
      await _chatBox?.delete('chat_history');
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear chat history: ${e.toString()}',
      );
    }
  }

  // Nutrition Box Methods
  Future<void> cacheRecentMeals(List<Map<String, dynamic>> meals) async {
    try {
      await _nutritionBox?.put('recent_meals', meals);
    } catch (e) {
      throw CacheException(
        message: 'Failed to cache recent meals: ${e.toString()}',
      );
    }
  }

  List<Map<String, dynamic>>? getCachedRecentMeals() {
    try {
      final data = _nutritionBox?.get('recent_meals');
      if (data == null) return null;
      return (data as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (e) {
      throw CacheException(
        message: 'Failed to get cached recent meals: ${e.toString()}',
      );
    }
  }

  // Workout Box Methods
  Future<void> cacheRecentWorkouts(List<Map<String, dynamic>> workouts) async {
    try {
      await _workoutBox?.put('recent_workouts', workouts);
    } catch (e) {
      throw CacheException(
        message: 'Failed to cache recent workouts: ${e.toString()}',
      );
    }
  }

  List<Map<String, dynamic>>? getCachedRecentWorkouts() {
    try {
      final data = _workoutBox?.get('recent_workouts');
      if (data == null) return null;
      return (data as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (e) {
      throw CacheException(
        message: 'Failed to get cached recent workouts: ${e.toString()}',
      );
    }
  }

  // Settings Box Methods
  Future<void> saveSetting(String key, dynamic value) async {
    try {
      await _settingsBox?.put(key, value);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save setting: ${e.toString()}',
      );
    }
  }

  dynamic getSetting(String key, {dynamic defaultValue}) {
    try {
      return _settingsBox?.get(key, defaultValue: defaultValue);
    } catch (e) {
      throw CacheException(
        message: 'Failed to get setting: ${e.toString()}',
      );
    }
  }

  Future<void> deleteSetting(String key) async {
    try {
      await _settingsBox?.delete(key);
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete setting: ${e.toString()}',
      );
    }
  }

  // Theme preference
  Future<void> saveThemeMode(String themeMode) async {
    await saveSetting('theme_mode', themeMode);
  }

  String getThemeMode() {
    return getSetting('theme_mode', defaultValue: 'light') as String;
  }

  // Onboarding status
  Future<void> setOnboardingCompleted(bool completed) async {
    await saveSetting('onboarding_completed', completed);
  }

  bool isOnboardingCompleted() {
    return getSetting('onboarding_completed', defaultValue: false) as bool;
  }

  // First launch
  Future<void> setFirstLaunch(bool firstLaunch) async {
    await saveSetting('first_launch', firstLaunch);
  }

  bool isFirstLaunch() {
    return getSetting('first_launch', defaultValue: true) as bool;
  }

  // Clear all data
  Future<void> clearAll() async {
    try {
      await _authBox?.clear();
      await _userBox?.clear();
      await _chatBox?.clear();
      await _nutritionBox?.clear();
      await _workoutBox?.clear();
      // Keep settings box to preserve user preferences
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear all data: ${e.toString()}',
      );
    }
  }

  // Close all boxes
  Future<void> close() async {
    try {
      await _authBox?.close();
      await _userBox?.close();
      await _chatBox?.close();
      await _nutritionBox?.close();
      await _workoutBox?.close();
      await _settingsBox?.close();
    } catch (e) {
      throw CacheException(
        message: 'Failed to close boxes: ${e.toString()}',
      );
    }
  }
}
