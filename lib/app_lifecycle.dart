import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/di/injection_container.dart';
import 'domain/entities/auth_status.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/integrated_chat_provider.dart';
import 'services/integrated_meal_check_scheduler.dart';

/// Manages app lifecycle events and initialization
class AppLifecycle {
  static bool _initialized = false;

  /// Initialize app lifecycle (start scheduler)
  static void initialize(WidgetRef ref) {
    // Prevent multiple initializations
    if (_initialized) {
      return;
    }
    _initialized = true;

    // Get scheduler from DI container
    final scheduler = getIt<IntegratedMealCheckScheduler>();

    // Start the scheduler with callback
    scheduler.start(
      onCheckIn: (period) {
        // Get current user name
        final authState = ref.read(authProvider);
        var userName = 'there';

        authState.whenData((status) {
          if (status is Authenticated) {
            userName = status.user.displayName;
          }
        });

        // Trigger check-in message in chat
        ref.read(integratedChatProvider.notifier).addCheckInMessage(
              period,
              userName,
            );
      },
    );
  }

  /// Clean up resources
  static void dispose() {
    if (!_initialized) {
      return;
    }

    final scheduler = getIt<IntegratedMealCheckScheduler>();
    scheduler.stop();
    _initialized = false;
  }
}
