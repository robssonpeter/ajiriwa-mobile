import 'package:equatable/equatable.dart';

import '../../domain/entities/job_apply_response.dart';

/// Job apply response model
class JobApplyResponseModel extends Equatable {
  /// Application ID
  final int applicationId;

  /// Application status
  final String status;

  /// Submission timestamp
  final String submittedAt;

  /// Constructor
  const JobApplyResponseModel({
    required this.applicationId,
    required this.status,
    required this.submittedAt,
  });

  /// Convert model to entity
  JobApplyResponse toEntity() {
    return JobApplyResponse(
      applicationId: applicationId,
      status: status,
      submittedAt: submittedAt,
    );
  }

  /// Create model from JSON
  factory JobApplyResponseModel.fromJson(Map<String, dynamic> json) {
    return JobApplyResponseModel(
      applicationId: json['application_id'] ?? 0,
      status: json['status'] ?? 'unknown',
      submittedAt: json['submitted_at'] ?? '',
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'application_id': applicationId,
      'status': status,
      'submitted_at': submittedAt,
    };
  }

  @override
  List<Object?> get props => [applicationId, status, submittedAt];
}

/// Job apply intent response model
class JobApplyIntentResponseModel extends Equatable {
  /// Whether the intent was tracked
  final bool tracked;

  /// Application ID (if created)
  final int? applicationId;

  /// Constructor
  const JobApplyIntentResponseModel({
    required this.tracked,
    this.applicationId,
  });

  /// Convert model to entity
  JobApplyIntentResponse toEntity() {
    return JobApplyIntentResponse(
      tracked: tracked,
      applicationId: applicationId,
    );
  }

  /// Create model from JSON
  factory JobApplyIntentResponseModel.fromJson(Map<String, dynamic> json) {
    return JobApplyIntentResponseModel(
      tracked: json['tracked'] ?? false,
      applicationId: json['application_id'],
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'tracked': tracked,
      if (applicationId != null) 'application_id': applicationId,
    };
  }

  @override
  List<Object?> get props => [tracked, applicationId];
}