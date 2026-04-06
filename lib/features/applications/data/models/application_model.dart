import '../../domain/entities/application.dart';

/// Model class for Application
class ApplicationModel {
  /// Job title
  final String jobTitle;
  
  /// Job ID
  final int jobId;
  
  /// Date when the application was submitted
  final String appliedOn;
  
  /// Status of the application
  final String applicationStatus;
  
  /// Current status of the application
  final String currentStatus;
  
  /// Time ago in human readable format
  final String timeAgo;
  
  /// Company name
  final String companyName;

  final int applicationId;

  /// Constructor
  const ApplicationModel({
    required this.jobTitle,
    required this.jobId,
    required this.appliedOn,
    required this.applicationStatus,
    required this.currentStatus,
    required this.timeAgo,
    required this.companyName,
    required this.applicationId,
  });

  /// Create an ApplicationModel from JSON
  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      jobTitle: json['job_title'] as String? ?? '',
      jobId: json['job_id'] as int,
      appliedOn: json['applied_on'] as String,
      applicationStatus: json['application_status'] as String,
      currentStatus: json['current_status'] as String,
      timeAgo: json['time_ago'] as String,
      companyName: json['company_name'] as String? ?? '',
      applicationId: json['application_id']
    );
  }

  /// Convert model to entity
  Application toEntity() {
    return Application(
      jobTitle: jobTitle,
      jobId: jobId,
      appliedOn: appliedOn,
      applicationStatus: applicationStatus,
      currentStatus: currentStatus,
      timeAgo: timeAgo,
      companyName: companyName,
      applicationId: applicationId,
    );
  }
}