import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/dashboard.dart';

/// Repository interface for dashboard data
abstract class DashboardRepository {
  /// Get dashboard data
  Future<Either<Failure, Dashboard>> getDashboard();
}