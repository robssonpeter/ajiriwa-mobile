import 'package:equatable/equatable.dart';

/// Job apply response entity
class JobApplyResponse extends Equatable {
  /// Application ID
  final int applicationId;

  /// Application status
  final String status;

  /// Submission timestamp
  final String submittedAt;

  /// Constructor
  const JobApplyResponse({
    required this.applicationId,
    required this.status,
    required this.submittedAt,
  });

  @override
  List<Object?> get props => [applicationId, status, submittedAt];
}

/// Job apply intent response entity
class JobApplyIntentResponse extends Equatable {
  /// Whether the intent was tracked
  final bool tracked;

  /// Application ID (if created)
  final int? applicationId;

  /// Constructor
  const JobApplyIntentResponse({
    required this.tracked,
    this.applicationId,
  });

  @override
  List<Object?> get props => [tracked, applicationId];
}