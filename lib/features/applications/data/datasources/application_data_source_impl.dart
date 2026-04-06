import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/applications_response_model.dart';
import '../models/application_details_model.dart';
import 'application_data_source.dart';

/// Implementation of the ApplicationDataSource interface
class ApplicationDataSourceImpl implements ApplicationDataSource {
  /// API client
  final ApiClient apiClient;

  /// Constructor
  ApplicationDataSourceImpl({
    required this.apiClient,
  });

  @override
  Future<ApplicationsResponseModel> getApplications({
    int? page,
    int? perPage,
  }) async {
    try {
      // Build query parameters
      final queryParameters = <String, dynamic>{};

      // Add pagination parameters
      if (page != null) {
        queryParameters['page'] = page;
      }

      if (perPage != null) {
        queryParameters['per_page'] = perPage;
      }

      final response = await apiClient.get('/applications', queryParameters: queryParameters);

      // Check if the response is null (skipped due to size limit)
      if (response == null) {
        throw ServerException('Response size exceeds limit');
      }

      return ApplicationsResponseModel.fromJson(response);
    } catch (e, stackTrace) {
      print('Applications Data Source Error: $e');
      print('Stack Trace: $stackTrace');
      if (e is ServerException) {
        throw e;
      } else {
        throw ServerException('Failed to load applications. Original error: ${e.runtimeType}');
      }
    }
  }

  @override
  Future<ApplicationDetailsModel> getApplicationDetails(int applicationId) async {
    try {
      final response = await apiClient.get('/applications/$applicationId');

      // Check if the response is null (skipped due to size limit)
      if (response == null) {
        throw ServerException('Response size exceeds limit');
      }

      return ApplicationDetailsModel.fromJson(response);
    } catch (e, stackTrace) {
      print('Application Details Data Source Error: $e');
      print('Stack Trace: $stackTrace');
      if (e is ServerException) {
        throw e;
      } else {
        throw ServerException('Failed to load application details. Original error: ${e.runtimeType}');
      }
    }
  }
}
