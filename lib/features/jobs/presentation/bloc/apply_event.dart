import 'package:equatable/equatable.dart';

/// Base class for all apply events
abstract class ApplyEvent extends Equatable {
  /// Constructor
  const ApplyEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check eligibility to apply for a job
class ApplyEligibilityRequested extends ApplyEvent {
  /// Job ID
  final int jobId;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const ApplyEligibilityRequested(this.jobId, {this.candidateId});

  @override
  List<Object?> get props => [jobId, candidateId];
}

/// Event to start the apply flow
class ApplyStarted extends ApplyEvent {
  /// Job ID
  final int jobId;

  /// Apply mode (ajiriwa, external_url, instructions)
  final String mode;

  /// Constructor
  const ApplyStarted({
    required this.jobId,
    required this.mode,
  });

  @override
  List<Object?> get props => [jobId, mode];
}

/// Event to load screening questions for a job
class ApplyScreeningLoaded extends ApplyEvent {
  /// Job ID
  final int jobId;

  /// Constructor
  const ApplyScreeningLoaded(this.jobId);

  @override
  List<Object?> get props => [jobId];
}

/// Event to submit an application
class ApplySubmitted extends ApplyEvent {
  /// Job ID
  final int jobId;

  /// Screening answers
  final List<Map<String, dynamic>> screeningAnswers;

  /// Resume ID
  final int resumeId;

  /// Cover letter
  final String? coverLetter;

  /// Attachments
  final List<Map<String, dynamic>>? attachments;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const ApplySubmitted({
    required this.jobId,
    required this.screeningAnswers,
    required this.resumeId,
    this.coverLetter,
    this.attachments,
    this.candidateId,
  });

  @override
  List<Object?> get props => [jobId, screeningAnswers, resumeId, coverLetter, attachments, candidateId];
}

/// Event to record apply intent for external URL or instruction-based applications
class ApplyExternalIntentRecorded extends ApplyEvent {
  /// Job ID
  final int jobId;

  /// Apply mode (external_url, instructions)
  final String mode;

  /// Notes
  final String? notes;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const ApplyExternalIntentRecorded({
    required this.jobId,
    required this.mode,
    this.notes,
    this.candidateId,
  });

  @override
  List<Object?> get props => [jobId, mode, notes, candidateId];
}

/// Event to mark an external application as applied
class ApplyExternalMarkedAsApplied extends ApplyEvent {
  /// Application ID
  final int applicationId;

  /// Constructor
  const ApplyExternalMarkedAsApplied(this.applicationId);

  @override
  List<Object?> get props => [applicationId];
}

/// Event to record external click for a job
class ApplyExternalClickRecorded extends ApplyEvent {
  /// Job ID
  final int jobId;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const ApplyExternalClickRecorded(this.jobId, {this.candidateId});

  @override
  List<Object?> get props => [jobId, candidateId];
}

/// Event to reset the apply state
class ApplyReset extends ApplyEvent {
  /// Constructor
  const ApplyReset();
}

/// Event to load apply context by slug
class ApplyContextRequested extends ApplyEvent {
  /// Job slug
  final String slug;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const ApplyContextRequested(this.slug, {this.candidateId});

  @override
  List<Object?> get props => [slug, candidateId];
}

/// Event to request the list of candidates (CVs) for the current user
class CandidatesRequested extends ApplyEvent {
  /// Constructor
  const CandidatesRequested();
}

/// Event to create a new candidate (CV) for the current user
class CandidateCreated extends ApplyEvent {
  /// Professional title
  final String professionalTitle;

  /// Constructor
  const CandidateCreated(this.professionalTitle);

  @override
  List<Object?> get props => [professionalTitle];
}

/// Event to select a candidate (CV) for the current application
class CandidateSelected extends ApplyEvent {
  /// Candidate ID
  final int candidateId;

  /// Constructor
  const CandidateSelected(this.candidateId);

  @override
  List<Object?> get props => [candidateId];
}

/// Event to generate an AI cover letter
class CoverLetterGenerated extends ApplyEvent {
  /// Job ID
  final int jobId;

  /// Starting point text (optional)
  final String? startingPoint;

  /// Refinement instructions (optional)
  final String? refineInstructions;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const CoverLetterGenerated({
    required this.jobId,
    this.startingPoint,
    this.refineInstructions,
    this.candidateId,
  });

  @override
  List<Object?> get props => [jobId, startingPoint, refineInstructions, candidateId];
}
