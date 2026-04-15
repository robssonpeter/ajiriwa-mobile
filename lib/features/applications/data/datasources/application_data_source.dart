import '../models/applications_response_model.dart';
import '../models/application_details_model.dart';

/// Data source interface for applications data
abstract class ApplicationDataSource {
  /// Get applications list from the API with optional filters
  Future<ApplicationsResponseModel> getApplications({
    int? page,
    int? perPage,
  });

  /// Get application details by ID
  Future<ApplicationDetailsModel> getApplicationDetails(int applicationId);

  /// Withdraw an application by ID
  Future<void> withdrawApplication(int applicationId);
}
