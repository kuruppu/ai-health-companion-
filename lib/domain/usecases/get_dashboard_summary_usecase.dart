import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../entities/dashboard_summary.dart';
import '../repositories/dashboard_repository.dart';

@injectable
class GetDashboardSummaryUseCase {
  final DashboardRepository _repository;

  GetDashboardSummaryUseCase(this._repository);

  Future<Either<Failure, DashboardSummary>> call(String userId) async {
    if (userId.isEmpty) {
      return const Left(
        ValidationFailure(message: 'User ID is required'),
      );
    }

    return await _repository.getDashboardSummary(userId);
  }
}
