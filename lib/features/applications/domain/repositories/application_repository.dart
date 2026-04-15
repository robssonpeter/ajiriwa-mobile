import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/applications_response.dart';
import '../entities/application_details.dart';

/// Repository interface for applications
abstract class ApplicationRepository {
  /// Get applications list from the API with optional filters
  Future<Either<Failure, ApplicationsResponse>> getApplications({
    int? page,
    int? perPage,
  });

  /// Get application details by ID
  Future<Either<Failure, ApplicationDetails>> getApplicationDetails(int applicationId);

  /// Withdraw an application by ID
  Future<Either<Failure, void>> withdrawApplication(int applicationId);
}
