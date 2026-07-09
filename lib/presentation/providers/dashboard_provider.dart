import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/di/injection_container.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/usecases/get_dashboard_summary_usecase.dart';
import '../../domain/usecases/log_energy_level_usecase.dart';
import '../providers/auth_provider.dart';

part 'dashboard_provider.g.dart';

@riverpod
class Dashboard extends _$Dashboard {
  late final GetDashboardSummaryUseCase _getDashboardSummaryUseCase;
  late final LogEnergyLevelUseCase _logEnergyLevelUseCase;

  @override
  Future<DashboardSummary> build() async {
    _getDashboardSummaryUseCase = getIt<GetDashboardSummaryUseCase>();
    _logEnergyLevelUseCase = getIt<LogEnergyLevelUseCase>();

    final user = ref.watch(authProvider).value?.getCurrentUser();

    if (user == null) {
      throw Exception('User not authenticated');
    }

    final result = await _getDashboardSummaryUseCase(user.userId);

    return result.fold(
      (failure) => throw Exception(failure.message),
      (summary) => summary,
    );
  }

  Future<void> logEnergyLevel(int energyLevel, {String? notes}) async {
    final user = ref.read(authProvider).value?.getCurrentUser();

    if (user == null) {
      throw Exception('User not authenticated');
    }

    state = const AsyncValue.loading();

    final result = await _logEnergyLevelUseCase(
      userId: user.userId,
      energyLevel: energyLevel,
      notes: notes,
    );

    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (_) async {
        // Refresh dashboard
        final summaryResult = await _getDashboardSummaryUseCase(user.userId);
        state = summaryResult.fold(
          (failure) => AsyncValue.error(failure.message, StackTrace.current),
          AsyncValue.data,
        );
      },
    );
  }

  Future<void> refresh() async {
    final user = ref.read(authProvider).value?.getCurrentUser();

    if (user == null) {
      return;
    }

    state = const AsyncValue.loading();

    final result = await _getDashboardSummaryUseCase(user.userId);

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      AsyncValue.data,
    );
  }
}
