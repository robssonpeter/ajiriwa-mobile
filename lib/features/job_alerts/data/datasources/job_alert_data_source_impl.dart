import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/job_alert_model.dart';
import 'job_alert_data_source.dart';

class JobAlertDataSourceImpl implements JobAlertDataSource {
  final ApiClient apiClient;

  JobAlertDataSourceImpl({required this.apiClient});

  @override
  Future<List<JobAlertModel>> getAlerts() async {
    try {
      final response = await apiClient.get('/job-alerts');
      if (response == null) throw ServerException('Empty response');
      final list = response as List<dynamic>;
      return list.map((e) => JobAlertModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e, st) {
      appLogger.e('JobAlertDataSource.getAlerts', error: e, stackTrace: st);
      if (e is ServerException) rethrow;
      throw ServerException('Failed to load job alerts: ${e.runtimeType}');
    }
  }

  @override
  Future<JobAlertModel> createAlert({
    required String name,
    String? keywords,
    String? location,
    int? jobTypeId,
    bool isRemote = false,
  }) async {
    try {
      final response = await apiClient.post('/job-alerts', data: {
        'name': name,
        if (keywords != null) 'keywords': keywords,
        if (location != null) 'location': location,
        if (jobTypeId != null) 'job_type_id': jobTypeId,
        'is_remote': isRemote,
      });
      if (response == null) throw ServerException('Empty response');
      return JobAlertModel.fromJson(response as Map<String, dynamic>);
    } catch (e, st) {
      appLogger.e('JobAlertDataSource.createAlert', error: e, stackTrace: st);
      if (e is ServerException) rethrow;
      throw ServerException('Failed to create job alert: ${e.runtimeType}');
    }
  }

  @override
  Future<JobAlertModel> updateAlert({
    required int id,
    required String name,
    String? keywords,
    String? location,
    int? jobTypeId,
    bool isRemote = false,
    bool isActive = true,
  }) async {
    try {
      final response = await apiClient.put('/job-alerts/$id', data: {
        'name': name,
        'keywords': keywords,
        'location': location,
        'job_type_id': jobTypeId,
        'is_remote': isRemote,
        'is_active': isActive,
      });
      if (response == null) throw ServerException('Empty response');
      return JobAlertModel.fromJson(response as Map<String, dynamic>);
    } catch (e, st) {
      appLogger.e('JobAlertDataSource.updateAlert', error: e, stackTrace: st);
      if (e is ServerException) rethrow;
      throw ServerException('Failed to update job alert: ${e.runtimeType}');
    }
  }

  @override
  Future<void> deleteAlert(int id) async {
    try {
      await apiClient.delete('/job-alerts/$id');
    } catch (e, st) {
      appLogger.e('JobAlertDataSource.deleteAlert', error: e, stackTrace: st);
      if (e is ServerException) rethrow;
      throw ServerException('Failed to delete job alert: ${e.runtimeType}');
    }
  }
}
