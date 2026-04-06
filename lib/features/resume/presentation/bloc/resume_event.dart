part of 'resume_bloc.dart';

/// Base class for resume events
abstract class ResumeEvent extends Equatable {
  /// Constructor
  const ResumeEvent();

  @override
  List<Object?> get props => [];
}

/// Event to get resume section data
class GetResumeSection extends ResumeEvent {
  /// Section name
  final String section;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const GetResumeSection({
    required this.section,
    this.candidateId,
  });

  @override
  List<Object?> get props => [section, candidateId];
}

/// Event to update personal information
class UpdatePersonal extends ResumeEvent {
  /// Personal information
  final Personal personal;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const UpdatePersonal({
    required this.personal,
    this.candidateId,
  });

  @override
  List<Object?> get props => [personal, candidateId];
}

/// Event to update career information
class UpdateCareer extends ResumeEvent {
  /// Career information
  final Career career;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const UpdateCareer({
    required this.career,
    this.candidateId,
  });

  @override
  List<Object?> get props => [career, candidateId];
}

/// Event to add work experience
class AddExperience extends ResumeEvent {
  /// Experience information
  final Experience experience;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const AddExperience({
    required this.experience,
    this.candidateId,
  });

  @override
  List<Object?> get props => [experience, candidateId];
}

/// Event to update work experience
class UpdateExperience extends ResumeEvent {
  /// Experience information
  final Experience experience;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const UpdateExperience({
    required this.experience,
    this.candidateId,
  });

  @override
  List<Object?> get props => [experience, candidateId];
}

/// Event to delete work experience
class DeleteExperience extends ResumeEvent {
  /// Experience ID
  final int experienceId;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const DeleteExperience({
    required this.experienceId,
    this.candidateId,
  });

  @override
  List<Object?> get props => [experienceId, candidateId];
}

/// Event to add education
class AddEducation extends ResumeEvent {
  /// Education information
  final Education education;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const AddEducation({
    required this.education,
    this.candidateId,
  });

  @override
  List<Object?> get props => [education, candidateId];
}

/// Event to update education
class UpdateEducation extends ResumeEvent {
  /// Education information
  final Education education;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const UpdateEducation({
    required this.education,
    this.candidateId,
  });

  @override
  List<Object?> get props => [education, candidateId];
}

/// Event to delete education
class DeleteEducation extends ResumeEvent {
  /// Education ID
  final int educationId;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const DeleteEducation({
    required this.educationId,
    this.candidateId,
  });

  @override
  List<Object?> get props => [educationId, candidateId];
}

/// Event to add language
class AddLanguage extends ResumeEvent {
  /// Language information
  final Language language;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const AddLanguage({
    required this.language,
    this.candidateId,
  });

  @override
  List<Object?> get props => [language, candidateId];
}

/// Event to update language
class UpdateLanguage extends ResumeEvent {
  /// Language information
  final Language language;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const UpdateLanguage({
    required this.language,
    this.candidateId,
  });

  @override
  List<Object?> get props => [language, candidateId];
}

/// Event to delete language
class DeleteLanguage extends ResumeEvent {
  /// Language ID
  final int languageId;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const DeleteLanguage({
    required this.languageId,
    this.candidateId,
  });

  @override
  List<Object?> get props => [languageId, candidateId];
}

/// Event to add skill
class AddSkill extends ResumeEvent {
  /// Skill information
  final Skill skill;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const AddSkill({
    required this.skill,
    this.candidateId,
  });

  @override
  List<Object?> get props => [skill, candidateId];
}

/// Event to update skill
class UpdateSkill extends ResumeEvent {
  /// Skill information
  final Skill skill;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const UpdateSkill({
    required this.skill,
    this.candidateId,
  });

  @override
  List<Object?> get props => [skill, candidateId];
}

/// Event to delete skill
class DeleteSkill extends ResumeEvent {
  /// Skill ID
  final int skillId;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const DeleteSkill({
    required this.skillId,
    this.candidateId,
  });

  @override
  List<Object?> get props => [skillId, candidateId];
}

/// Event to add award
class AddAward extends ResumeEvent {
  /// Award information
  final Award award;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const AddAward({
    required this.award,
    this.candidateId,
  });

  @override
  List<Object?> get props => [award, candidateId];
}

/// Event to update award
class UpdateAward extends ResumeEvent {
  /// Award information
  final Award award;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const UpdateAward({
    required this.award,
    this.candidateId,
  });

  @override
  List<Object?> get props => [award, candidateId];
}

/// Event to delete award
class DeleteAward extends ResumeEvent {
  /// Award ID
  final int awardId;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const DeleteAward({
    required this.awardId,
    this.candidateId,
  });

  @override
  List<Object?> get props => [awardId, candidateId];
}

/// Event to add reference
class AddReference extends ResumeEvent {
  /// Reference information
  final Reference reference;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const AddReference({
    required this.reference,
    this.candidateId,
  });

  @override
  List<Object?> get props => [reference, candidateId];
}

/// Event to update reference
class UpdateReference extends ResumeEvent {
  /// Reference information
  final Reference reference;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const UpdateReference({
    required this.reference,
    this.candidateId,
  });

  @override
  List<Object?> get props => [reference, candidateId];
}

/// Event to delete reference
class DeleteReference extends ResumeEvent {
  /// Reference ID
  final int referenceId;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const DeleteReference({
    required this.referenceId,
    this.candidateId,
  });

  @override
  List<Object?> get props => [referenceId, candidateId];
}

/// Event to get complete resume data
class GetResumeData extends ResumeEvent {
  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const GetResumeData({
    this.candidateId,
  });

  @override
  List<Object?> get props => [candidateId];
}

/// Event to get rendered resume HTML
class GetResumeHtml extends ResumeEvent {
  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const GetResumeHtml({
    this.candidateId,
  });

  @override
  List<Object?> get props => [candidateId];
}
