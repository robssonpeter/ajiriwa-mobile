import '../../domain/entities/job_alert.dart';

class JobAlertModel extends JobAlert {
  const JobAlertModel({
    required super.id,
    required super.name,
    super.keywords,
    super.location,
    super.jobTypeId,
    super.jobTypeName,
    required super.isRemote,
    required super.isActive,
    super.lastNotifiedAt,
    required super.createdAt,
  });

  factory JobAlertModel.fromJson(Map<String, dynamic> json) {
    final jobType = json['job_type'] as Map<String, dynamic>?;
    return JobAlertModel(
      id: json['id'],
      name: json['name'] ?? 'My Job Alert',
      keywords: json['keywords'],
      location: json['location'],
      jobTypeId: json['job_type_id'],
      jobTypeName: jobType?['name'],
      isRemote: json['is_remote'] == true || json['is_remote'] == 1,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      lastNotifiedAt: json['last_notified_at'],
      createdAt: json['created_at'] ?? '',
    );
  }

  JobAlert toEntity() => this;
}
