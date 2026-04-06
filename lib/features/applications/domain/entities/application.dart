import 'package:equatable/equatable.dart';

/// Application entity representing a job application
class Application extends Equatable {
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
  const Application({
    required this.jobTitle,
    required this.jobId,
    required this.appliedOn,
    required this.applicationStatus,
    required this.currentStatus,
    required this.timeAgo,
    required this.companyName,
    required this.applicationId,
  });

  @override
  List<Object?> get props => [
    jobTitle,
    jobId,
    appliedOn,
    applicationStatus,
    currentStatus,
    timeAgo,
    companyName,
    applicationId
  ];
}