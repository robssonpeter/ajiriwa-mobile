import 'package:equatable/equatable.dart';

/// Job eligibility entity
class JobEligibility extends Equatable {
  /// Whether the user is eligible to apply
  final bool eligible;

  /// Profile completion details
  final ProfileCompletion profileCompletion;

  /// Job requirements details
  final JobRequirements jobRequirements;

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
  const JobEligibility({
    required this.eligible,
    required this.profileCompletion,
    required this.jobRequirements,
    required this.screeningRequired,
    required this.hasExternalUrl,
    required this.hasInstructionInDescription,
    required this.applicationMethod,
    this.reason,
  });

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

/// Profile completion entity
class ProfileCompletion extends Equatable {
  /// Profile completion percentage
  final int percentage;

  /// Missing sections
  final List<String> missingSections;

  /// Critical missing sections
  final List<String> criticalMissing;

  /// Constructor
  const ProfileCompletion({
    required this.percentage,
    required this.missingSections,
    required this.criticalMissing,
  });

  @override
  List<Object?> get props => [percentage, missingSections, criticalMissing];
}

/// Job requirements entity
class JobRequirements extends Equatable {
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
  const JobRequirements({
    this.minEducation,
    this.minExperienceYears,
    required this.requiredSkills,
    required this.missingSkills,
    required this.meetsRequirements,
  });

  @override
  List<Object?> get props => [
        minEducation,
        minExperienceYears,
        requiredSkills,
        missingSkills,
        meetsRequirements,
      ];
}
