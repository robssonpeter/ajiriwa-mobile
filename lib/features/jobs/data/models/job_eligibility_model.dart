import 'package:equatable/equatable.dart';

import '../../domain/entities/job_eligibility.dart';

/// Job eligibility model
class JobEligibilityModel extends Equatable {
  /// Whether the user is eligible to apply
  final bool eligible;

  /// Profile completion details
  final ProfileCompletionModel profileCompletion;

  /// Job requirements details
  final JobRequirementsModel jobRequirements;

  /// Whether screening is required
  final bool screeningRequired;

  /// Whether the job has an external URL
  final bool hasExternalUrl;

  /// Whether the job has instructions in the description
  final bool hasInstructionInDescription;

  /// Application method (ajiriwa, url, email, description)
  final String applicationMethod;

  /// Reason for ineligibility
  final String? reason;

  /// Constructor
  const JobEligibilityModel({
    required this.eligible,
    required this.profileCompletion,
    required this.jobRequirements,
    required this.screeningRequired,
    required this.hasExternalUrl,
    required this.hasInstructionInDescription,
    required this.applicationMethod,
    this.reason,
  });

  /// Convert model to entity
  JobEligibility toEntity() {
    return JobEligibility(
      eligible: eligible,
      profileCompletion: profileCompletion.toEntity(),
      jobRequirements: jobRequirements.toEntity(),
      screeningRequired: screeningRequired,
      hasExternalUrl: hasExternalUrl,
      hasInstructionInDescription: hasInstructionInDescription,
      applicationMethod: applicationMethod,
      reason: reason,
    );
  }

  /// Create model from JSON
  factory JobEligibilityModel.fromJson(Map<String, dynamic> json) {
    print('JobEligibilityModel.fromJson - Raw JSON: $json');
    print('JobEligibilityModel.fromJson - application_method: ${json['application_method']}');
    print('JobEligibilityModel.fromJson - apply_method: ${json['apply_method']}');

    return JobEligibilityModel(
      eligible: json['eligible'] ?? false,
      profileCompletion: ProfileCompletionModel.fromJson(json['profile_completion'] ?? {}),
      jobRequirements: JobRequirementsModel.fromJson(json['job_requirements'] ?? {}),
      screeningRequired: json['screening_required'] ?? false,
      hasExternalUrl: json['has_external_url'] ?? false,
      hasInstructionInDescription: json['has_instruction_in_description'] ?? false,
      applicationMethod: json['application_method'] ?? json['apply_method'] ?? 'ajiriwa',
      reason: json['reason'],
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'eligible': eligible,
      'profile_completion': profileCompletion.toJson(),
      'job_requirements': jobRequirements.toJson(),
      'screening_required': screeningRequired,
      'has_external_url': hasExternalUrl,
      'has_instruction_in_description': hasInstructionInDescription,
      'application_method': applicationMethod,
      'reason': reason,
    };
  }

  @override
  List<Object?> get props => [
        eligible,
        profileCompletion,
        jobRequirements,
        screeningRequired,
        hasExternalUrl,
        hasInstructionInDescription,
        applicationMethod,
        reason,
      ];
}

/// Profile completion model
class ProfileCompletionModel extends Equatable {
  /// Profile completion percentage
  final int percentage;

  /// Missing sections
  final List<String> missingSections;

  /// Critical missing sections
  final List<String> criticalMissing;

  /// Constructor
  const ProfileCompletionModel({
    required this.percentage,
    required this.missingSections,
    required this.criticalMissing,
  });

  /// Convert model to entity
  ProfileCompletion toEntity() {
    return ProfileCompletion(
      percentage: percentage,
      missingSections: missingSections,
      criticalMissing: criticalMissing,
    );
  }

  /// Create model from JSON
  factory ProfileCompletionModel.fromJson(Map<String, dynamic> json) {
    return ProfileCompletionModel(
      percentage: json['percentage'] ?? 0,
      missingSections: List<String>.from(json['missing_sections'] ?? []),
      criticalMissing: List<String>.from(json['critical_missing'] ?? []),
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'percentage': percentage,
      'missing_sections': missingSections,
      'critical_missing': criticalMissing,
    };
  }

  @override
  List<Object?> get props => [percentage, missingSections, criticalMissing];
}

/// Job requirements model
class JobRequirementsModel extends Equatable {
  /// Minimum education
  final String? minEducation;

  /// Minimum experience years
  final int? minExperienceYears;

  /// Required skills
  final List<String> requiredSkills;

  /// Missing skills
  final List<String> missingSkills;

  /// Whether the user meets the requirements
  final bool meetsRequirements;

  /// Constructor
  const JobRequirementsModel({
    this.minEducation,
    this.minExperienceYears,
    required this.requiredSkills,
    required this.missingSkills,
    required this.meetsRequirements,
  });

  /// Convert model to entity
  JobRequirements toEntity() {
    return JobRequirements(
      minEducation: minEducation,
      minExperienceYears: minExperienceYears,
      requiredSkills: requiredSkills,
      missingSkills: missingSkills,
      meetsRequirements: meetsRequirements,
    );
  }

  /// Create model from JSON
  factory JobRequirementsModel.fromJson(Map<String, dynamic> json) {
    return JobRequirementsModel(
      minEducation: json['min_education'],
      minExperienceYears: json['min_experience_years'],
      requiredSkills: List<String>.from(json['required_skills'] ?? []),
      missingSkills: List<String>.from(json['missing_skills'] ?? []),
      meetsRequirements: json['meets_requirements'] ?? false,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'min_education': minEducation,
      'min_experience_years': minExperienceYears,
      'required_skills': requiredSkills,
      'missing_skills': missingSkills,
      'meets_requirements': meetsRequirements,
    };
  }

  @override
  List<Object?> get props => [
        minEducation,
        minExperienceYears,
        requiredSkills,
        missingSkills,
        meetsRequirements,
      ];
}
