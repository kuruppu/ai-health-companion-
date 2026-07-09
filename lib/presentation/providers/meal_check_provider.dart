import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/di/injection_container.dart';
import '../../domain/entities/meal_check_in.dart';
import '../../services/meal_check_scheduler.dart';
import '../../services/meal_check_service.dart';
import 'auth_provider.dart';

part 'meal_check_provider.g.dart';

/// Provider for meal check-in system
@riverpod
class MealCheckNotifier extends _$MealCheckNotifier {
  late final MealCheckService _checkService;
  late final MealCheckScheduler _scheduler;

  @override
  Future<void> build() async {
    _checkService = getIt<MealCheckService>();
    _scheduler = getIt<MealCheckScheduler>();

    // Listen for scheduled check-ins
    _scheduler.addListener(_handleScheduledCheckIn);

    return; // Explicitly return void
  }

  /// Handle scheduled check-in trigger
  void _handleScheduledCheckIn(MealPeriod period) async {
    final authState = ref.read(authProvider);
    final user = authState.value?.getCurrentUser();

    if (user == null) return;

    // Check if user needs check-in
    if (_checkService.needsCheckIn(user.userId, period)) {
      // Trigger AI message (handled by chat provider)
      ref
          .read(mealCheckChatProvider.notifier)
          .triggerCheckInMessage(period, user.displayName ?? 'there');
    }
  }

  /// Record meal logged (called from nutrition screen)
  void recordMealLogged(String userId) {
    _checkService.recordMealLogged(userId, DateTime.now());
  }

  /// Record check-in response
  MealCheckIn recordResponse({
    required String userId,
    required MealPeriod period,
    required bool hadEaten,
    String? response,
    String? mealId,
  }) {
    return _checkService.recordCheckIn(
      userId: userId,
      period: period,
      hadEaten: hadEaten,
      response: response,
      mealId: mealId,
    );
  }

  /// Get skip rate
  double getSkipRate(String userId) {
    return _checkService.getMealSkipRate(userId);
  }

  /// Get most skipped period
  MealPeriod? getMostSkippedPeriod(String userId) {
    return _checkService.getMostSkippedPeriod(userId);
  }

  /// Manually trigger check-in (for testing)
  void triggerManualCheckIn(MealPeriod period) {
    _scheduler.triggerCheckIn(period);
  }
}

/// Provider for meal check-in chat integration
@riverpod
class MealCheckChat extends _$MealCheckChat {
  late final MealCheckService _checkService;
  MealPeriod? _pendingCheckIn;

  @override
  Future<void> build() async {
    _checkService = getIt<MealCheckService>();
    return; // Explicitly return void
  }

  /// Trigger AI check-in message
  void triggerCheckInMessage(MealPeriod period, String userName) {
    _pendingCheckIn = period;

    final message = _checkService.generateCheckInMessage(period, userName);

    // Send message through chat system
    // This will be handled by adding message to chat provider
    ref.read(pendingCheckInMessageProvider.notifier).state = message;
    ref.read(pendingCheckInPeriodProvider.notifier).state = period;
  }

  /// Handle user response to check-in
  void handleResponse({
    required String userId,
    required bool hadEaten,
    String? response,
    String? mealId,
  }) {
    if (_pendingCheckIn == null) return;

    _checkService.recordCheckIn(
      userId: userId,
      period: _pendingCheckIn!,
      hadEaten: hadEaten,
      response: response,
      mealId: mealId,
    );

    // Clear pending check-in
    _pendingCheckIn = null;
    ref.read(pendingCheckInMessageProvider.notifier).state = null;
    ref.read(pendingCheckInPeriodProvider.notifier).state = null;
  }

  /// Get pending check-in period
  MealPeriod? get pendingPeriod => _pendingCheckIn;
}

/// State provider for pending check-in message
@riverpod
class PendingCheckInMessage extends _$PendingCheckInMessage {
  @override
  String? build() => null;
}

/// State provider for pending check-in period
@riverpod
class PendingCheckInPeriod extends _$PendingCheckInPeriod {
  @override
  MealPeriod? build() => null;
}
