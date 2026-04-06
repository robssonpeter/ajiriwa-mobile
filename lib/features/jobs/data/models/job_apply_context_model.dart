import 'package:equatable/equatable.dart';

import '../../domain/entities/job_apply_context.dart';
import 'job_details_model.dart';

/// Job apply context model
class JobApplyContextModel extends Equatable {
  /// Job details
  final JobDetailsModel job;

  /// Candidate information
  final CandidateModel candidate;

  /// Certificates
  final List<CertificateModel> certificates;

  /// Whether the user has already applied for this job
  final bool applied;

  /// Application information (if already applied)
  final JobApplicationModel? application;

  /// Remembered application information (if any)
  final Map<String, dynamic>? remembered;

  /// Constructor
  const JobApplyContextModel({
    required this.job,
    required this.candidate,
    required this.certificates,
    required this.applied,
    this.application,
    this.remembered,
  });

  /// Convert model to entity
  JobApplyContext toEntity() {
    return JobApplyContext(
      job: job.toEntity(),
      candidate: candidate.toEntity(),
      certificates: certificates.map((c) => c.toEntity()).toList(),
      applied: applied,
      application: application?.toEntity(),
      remembered: remembered,
    );
  }

  /// Create model from JSON
  factory JobApplyContextModel.fromJson(Map<String, dynamic> json) {
    return JobApplyContextModel(
      job: JobDetailsModel.fromJson(json['job'] as Map<String, dynamic>),
      candidate: CandidateModel.fromJson(json['candidate'] as Map<String, dynamic>),
      certificates: (json['certificates'] as List<dynamic>)
          .map((c) => CertificateModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      applied: json['applied'] as bool,
      application: json['application'] != null
          ? JobApplicationModel.fromJson(json['application'] as Map<String, dynamic>)
          : null,
      remembered: json['remembered'] as Map<String, dynamic>?,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'job': job.toJson(),
      'candidate': candidate.toJson(),
      'certificates': certificates.map((c) => c.toJson()).toList(),
      'applied': applied,
      if (application != null) 'application': application!.toJson(),
      if (remembered != null) 'remembered': remembered,
    };
  }

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

/// Candidate model
class CandidateModel extends Equatable {
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
  const CandidateModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.professionalTitle,
    required this.profileCompletion,
  });

  /// Convert model to entity
  Candidate toEntity() {
    return Candidate(
      id: id,
      firstName: firstName,
      lastName: lastName,
      professionalTitle: professionalTitle,
      profileCompletion: profileCompletion,
    );
  }

  /// Create model from JSON
  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    return CandidateModel(
      id: json['id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      professionalTitle: json['professional_title'] as String?,
      profileCompletion: json['profile_completion'] as int,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      if (professionalTitle != null) 'professional_title': professionalTitle,
      'profile_completion': profileCompletion,
    };
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        professionalTitle,
        profileCompletion,
      ];
}

/// Certificate model
class CertificateModel extends Equatable {
  /// Certificate label (name)
  final String label;

  /// Certificate code (ID)
  final int code;

  /// Constructor
  const CertificateModel({
    required this.label,
    required this.code,
  });

  /// Convert model to entity
  Certificate toEntity() {
    return Certificate(
      label: label,
      code: code,
    );
  }

  /// Create model from JSON
  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    return CertificateModel(
      label: json['label'] as String,
      code: json['code'] as int,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'code': code,
    };
  }

  @override
  List<Object?> get props => [label, code];
}

/// Job application model
class JobApplicationModel extends Equatable {
  /// Application ID
  final int id;

  /// Application status
  final String status;

  /// Application date
  final String appliedAt;

  /// Constructor
  const JobApplicationModel({
    required this.id,
    required this.status,
    required this.appliedAt,
  });

  /// Convert model to entity
  JobApplication toEntity() {
    return JobApplication(
      id: id,
      status: status,
      appliedAt: appliedAt,
    );
  }

  /// Create model from JSON
  factory JobApplicationModel.fromJson(Map<String, dynamic> json) {
    return JobApplicationModel(
      id: json['id'] as int,
      status: json['status'].toString(), // Convert to String regardless of original type
      appliedAt: json['application_date_time'] as String? ?? 
                json['applied_on'] as String? ?? 
                json['application_date'] as String? ?? 
                json['applied_at'] as String? ?? 
                'Unknown date',
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'applied_at': appliedAt,
    };
  }

  @override
  List<Object?> get props => [id, status, appliedAt];
}
