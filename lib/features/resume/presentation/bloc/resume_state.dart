part of 'resume_bloc.dart';

/// Base class for resume states
abstract class ResumeState extends Equatable {
  /// Constructor
  const ResumeState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ResumeInitial extends ResumeState {}

/// Loading state
class ResumeLoading extends ResumeState {}

/// Error state
class ResumeError extends ResumeState {
  /// Error message
  final String message;

  /// Constructor
  const ResumeError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State when resume section is loaded
class ResumeSectionLoaded extends ResumeState {
  /// Resume section response
  final ResumeSectionResponse response;

  /// Constructor
  const ResumeSectionLoaded({required this.response});

  @override
  List<Object?> get props => [response];
}

/// State when resume section is updated
class ResumeSectionUpdated extends ResumeState {
  /// Success message
  final String message;

  /// Constructor
  const ResumeSectionUpdated({this.message = 'Resume updated successfully'});

  @override
  List<Object?> get props => [message];
}

// Personal information states
/// State when personal information is updated
class PersonalUpdated extends ResumeState {
  /// Success message
  final String message;

  /// Constructor
  const PersonalUpdated({this.message = 'Personal information updated successfully'});

  @override
  List<Object?> get props => [message];
}

// Career information states
/// State when career information is updated
class CareerUpdated extends ResumeState {
  /// Success message
  final String message;

  /// Constructor
  const CareerUpdated({this.message = 'Career information updated successfully'});

  @override
  List<Object?> get props => [message];
}

// Experience states
/// State when experience is added
class ExperienceAdded extends ResumeState {
  /// Success message
  final String message;

  /// Constructor
  const ExperienceAdded({this.message = 'Experience added successfully'});

  @override
  List<Object?> get props => [message];
}

/// State when experience is updated
class ExperienceUpdated extends ResumeState {
  /// Success message
  final String message;

  /// Constructor
  const ExperienceUpdated({this.message = 'Experience updated successfully'});

  @override
  List<Object?> get props => [message];
}

/// State when experience is deleted
class ExperienceDeleted extends ResumeState {
  /// Success message
  final String message;

  /// Constructor
  const ExperienceDeleted({this.message = 'Experience deleted successfully'});

  @override
  List<Object?> get props => [message];
}

// Education states
/// State when education is added
class EducationAdded extends ResumeState {
  /// Success message
  final String message;

  /// Constructor
  const EducationAdded({this.message = 'Education added successfully'});

  @override
  List<Object?> get props => [message];
}

/// State when education is updated
class EducationUpdated extends ResumeState {
  /// Success message
  final String message;

  /// Constructor
  const EducationUpdated({this.message = 'Education updated successfully'});

  @override
  List<Object?> get props => [message];
}

/// State when education is deleted
class EducationDeleted extends ResumeState {
  /// Success message
  final String message;

  /// Constructor
  const EducationDeleted({this.message = 'Education deleted successfully'});

  @override
  List<Object?> get props => [message];
}

// Language states
/// State when language is added
class LanguageAdded extends ResumeState {
  /// Success message
  final String message;

  /// Constructor
  const LanguageAdded({this.message = 'Language added successfully'});

  @override
  List<Object?> get props => [message];
}

/// State when language is updated
class LanguageUpdated extends ResumeState {
  /// Success message
  final String message;

  /// Constructor
  const LanguageUpdated({this.message = 'Language updated successfully'});

  @override
  List<Object?> get props => [message];
}

/// State when language is deleted
class LanguageDeleted extends ResumeState {
  /// Success message
  final String message;

  /// Constructor
  const LanguageDeleted({this.message = 'Language deleted successfully'});

  @override
  List<Object?> get props => [message];
}

// Skill states
/// State when skill is added
class SkillAdded extends ResumeState {
  /// Success message
  final String message;

  /// Constructor
  const SkillAdded({this.message = 'Skill added successfully'});

  @override
  List<Object?> get props => [message];
}

/// State when skill is updated
class SkillUpdated extends ResumeState {
  /// Success message
  final String message;

  /// Constructor
  const SkillUpdated({this.message = 'Skill updated successfully'});

  @override
  List<Object?> get props => [message];
}

/// State when skill is deleted
class SkillDeleted extends ResumeState {
  /// Success message
  final String message;

  /// Constructor
  const SkillDeleted({this.message = 'Skill deleted successfully'});

  @override
  List<Object?> get props => [message];
}

// Award states
/// State when award is added
class AwardAdded extends ResumeState {
  /// Success message
  final String message;

  /// Constructor
  const AwardAdded({this.message = 'Award added successfully'});

  @override
  List<Object?> get props => [message];
}

/// State when award is updated
class AwardUpdated extends ResumeState {
  /// Success message
  final String message;

  /// Constructor
  const AwardUpdated({this.message = 'Award updated successfully'});

  @override
  List<Object?> get props => [message];
}

/// State when award is deleted
class AwardDeleted extends ResumeState {
  /// Success message
  final String message;

  /// Constructor
  const AwardDeleted({this.message = 'Award deleted successfully'});

  @override
  List<Object?> get props => [message];
}

// Reference states
/// State when reference is added
class ReferenceAdded extends ResumeState {
  /// Success message
  final String message;

  /// Constructor
  const ReferenceAdded({this.message = 'Reference added successfully'});

  @override
  List<Object?> get props => [message];
}

/// State when reference is updated
class ReferenceUpdated extends ResumeState {
  /// Success message
  final String message;

  /// Constructor
  const ReferenceUpdated({this.message = 'Reference updated successfully'});

  @override
  List<Object?> get props => [message];
}

/// State when reference is deleted
class ReferenceDeleted extends ResumeState {
  /// Success message
  final String message;

  /// Constructor
  const ReferenceDeleted({this.message = 'Reference deleted successfully'});

  @override
  List<Object?> get props => [message];
}

/// State when complete resume data is loaded
class ResumeDataLoaded extends ResumeState {
  /// Resume data
  final ResumeData resumeData;

  /// Constructor
  const ResumeDataLoaded({required this.resumeData});

  @override
  List<Object?> get props => [resumeData];
}

/// State when resume HTML is loaded
class ResumeHtmlLoaded extends ResumeState {
  /// Resume HTML
  final String html;

  /// Constructor
  const ResumeHtmlLoaded({required this.html});

  @override
  List<Object?> get props => [html];
}
