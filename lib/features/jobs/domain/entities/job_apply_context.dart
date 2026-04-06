import 'package:equatable/equatable.dart';

import 'job_details.dart';

/// Job apply context entity
class JobApplyContext extends Equatable {
  /// Job details
  final JobDetails job;

  /// Candidate information
  final Candidate candidate;

  /// Certificates
  final List<Certificate> certificates;

  /// Whether the user has already applied for this job
  final bool applied;

  /// Application information (if already applied)
  final JobApplication? application;

  /// Remembered application information (if any)
  final Map<String, dynamic>? remembered;

  /// Constructor
  const JobApplyContext({
    required this.job,
    required this.candidate,
    required this.certificates,
    required this.applied,
    this.application,
    this.remembered,
  });

  @override
  List<Object?> get props => [
        job,
        candidate,
        certificates,
        applied,
        application,
        remembered,
      ];
}

/// Candidate entity
class Candidate extends Equatable {
  /// Candidate ID
  final int id;

  /// First name
  final String firstName;

  /// Last name
  final String lastName;

  /// Professional title
  final String? professionalTitle;

  /// Profile completion percentage
  final int profileCompletion;

  /// Constructor
  const Candidate({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.professionalTitle,
    required this.profileCompletion,
  });

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        professionalTitle,
        profileCompletion,
      ];
}

/// Certificate entity
class Certificate extends Equatable {
  /// Certificate label (name)
  final String label;

  /// Certificate code (ID)
  final int code;

  /// Constructor
  const Certificate({
    required this.label,
    required this.code,
  });

  @override
  List<Object?> get props => [label, code];
}

/// Job application entity
class JobApplication extends Equatable {
  /// Application ID
  final int id;

  /// Application status
  final String status;

  /// Application date
  final String appliedAt;

  /// Constructor
  const JobApplication({
    required this.id,
    required this.status,
    required this.appliedAt,
  });

  @override
  List<Object?> get props => [id, status, appliedAt];
}