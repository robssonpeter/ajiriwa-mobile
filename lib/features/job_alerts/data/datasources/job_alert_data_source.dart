import '../models/job_alert_model.dart';

abstract class JobAlertDataSource {
  Future<List<JobAlertModel>> getAlerts();

  Future<JobAlertModel> createAlert({
    required String name,
    String? keywords,
    String? location,
    int? jobTypeId,
    bool isRemote,
  });

  Future<JobAlertModel> updateAlert({
    required int id,
    required String name,
    String? keywords,
    String? location,
    int? jobTypeId,
    bool isRemote,
    bool isActive,
  });

  Future<void> deleteAlert(int id);
}
