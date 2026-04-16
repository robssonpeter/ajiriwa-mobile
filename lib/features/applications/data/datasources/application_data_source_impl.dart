import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';
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
      appLogger.e('Applications Data Source Error', error: e, stackTrace: stackTrace);
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

      if (response == null) {
        throw ServerException('Empty response from server');
      }

      return ApplicationDetailsModel.fromJson(response);
    } catch (e, stackTrace) {
      appLogger.e('Application Details Data Source Error', error: e, stackTrace: stackTrace);
      if (e is ServerException) {
        throw e;
      } else {
        throw ServerException('Failed to load application details. Original error: ${e.runtimeType}');
      }
    }
  }

  @override
  Future<void> withdrawApplication(int applicationId) async {
    try {
      await apiClient.post('/applications/$applicationId/withdraw');
    } catch (e, stackTrace) {
      appLogger.e('Withdraw Application Error', error: e, stackTrace: stackTrace);
      if (e is ServerException) {
        throw e;
      } else {
        throw ServerException('Failed to withdraw application');
      }
    }
  }

  @override
  Future<Map<String, dynamic>> generateInterviewPrep(int scheduleId, {bool refresh = false}) async {
    try {
      final response = await apiClient.post(
        '/interviews/$scheduleId/prep',
        data: refresh ? {'refresh': true} : {},
      );
      if (response == null) throw ServerException('Empty response');
      return response as Map<String, dynamic>;
    } catch (e, stackTrace) {
      appLogger.e('Interview Prep Error', error: e, stackTrace: stackTrace);
      if (e is ServerException) rethrow;
      throw ServerException('Failed to generate interview prep: ${e.runtimeType}');
    }
  }
}
