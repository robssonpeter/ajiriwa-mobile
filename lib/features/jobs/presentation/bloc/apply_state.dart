import 'package:equatable/equatable.dart';

import '../../domain/entities/job_apply_context.dart';
import '../../domain/entities/job_apply_response.dart';
import '../../domain/entities/job_eligibility.dart';
import '../../domain/entities/job_screening.dart';

/// Base class for all apply states
abstract class ApplyState extends Equatable {
  /// Constructor
  const ApplyState();

  @override
  List<Object?> get props => [];
}

/// Initial apply state
class ApplyInitial extends ApplyState {}

/// State when checking eligibility
class ApplyCheckingEligibility extends ApplyState {}

/// State when eligibility check is complete
class ApplyEligibilityReady extends ApplyState {
  /// Whether the user is eligible to apply
  final bool eligible;

  /// Eligibility details
  final JobEligibility details;

  /// Constructor
  const ApplyEligibilityReady({
    required this.eligible,
    required this.details,
  });

  @override
  List<Object?> get props => [eligible, details];
}

/// State when a specific apply flow is required
class ApplyFlowRequired extends ApplyState {
  /// Apply mode (ajiriwa, external_url, instructions)
  final String mode;

  /// Screening questions (for ajiriwa mode)
  final JobScreening? screening;

  /// Profile hints (for ineligible users)
  final Map<String, dynamic>? profileHints;

  /// Constructor
  const ApplyFlowRequired({
    required this.mode,
    this.screening,
    this.profileHints,
  });

  @override
  List<Object?> get props => [mode, screening, profileHints];
}

/// State when submitting an application
class ApplySubmitting extends ApplyState {}

/// State when application is successful
class ApplySuccess extends ApplyState {
  /// Application ID
  final int applicationId;

  /// Apply mode (ajiriwa, external_url, instructions)
  final String mode;

  /// Constructor
  const ApplySuccess({
    required this.applicationId,
    required this.mode,
  });

  @override
  List<Object?> get props => [applicationId, mode];
}

/// State when application fails
class ApplyFailure extends ApplyState {
  /// Error message
  final String message;

  /// Error details
  final Map<String, dynamic>? details;

  /// Constructor
  const ApplyFailure({
    required this.message,
    this.details,
  });

  @override
  List<Object?> get props => [message, details];
}

/// State when external intent is recorded
class ApplyExternalIntentRecordedState extends ApplyState {
  /// Apply intent response
  final JobApplyIntentResponse response;

  /// Constructor
  const ApplyExternalIntentRecordedState(this.response);

  @override
  List<Object?> get props => [response];
}

/// State when external application is marked as applied
class ApplyExternalMarkedAsAppliedState extends ApplyState {
  /// Application ID
  final int applicationId;

  /// Constructor
  const ApplyExternalMarkedAsAppliedState(this.applicationId);

  @override
  List<Object?> get props => [applicationId];
}

/// State when apply context is loaded
class ApplyContextLoaded extends ApplyState {
  /// Apply context
  final JobApplyContext applyContext;

  /// Constructor
  const ApplyContextLoaded(this.applyContext);

  @override
  List<Object?> get props => [applyContext];
}

/// State when loading candidates
class CandidatesLoading extends ApplyState {}

/// State when candidates are loaded
class CandidatesLoaded extends ApplyState {
  /// Candidates list
  final Map<String, dynamic> candidates;

  /// Selected candidate ID
  final int? selectedCandidateId;

  /// Constructor
  const CandidatesLoaded(this.candidates, {this.selectedCandidateId});

  @override
  List<Object?> get props => [candidates, selectedCandidateId];
}

/// State when creating a candidate
class CandidateCreating extends ApplyState {}

/// State when a candidate is created
class CandidateCreatedState extends ApplyState {
  /// Created candidate
  final Map<String, dynamic> candidate;

  /// Constructor
  const CandidateCreatedState(this.candidate);

  @override
  List<Object?> get props => [candidate];
}

/// State when AI cover letter is being generated
class CoverLetterGenerating extends ApplyState {}

/// State when AI cover letter generation is successful
class CoverLetterGenerationSuccess extends ApplyState {
  /// Generated cover letter content
  final String content;

  /// Generation status (new, refined)
  final String status;

  /// Constructor
  const CoverLetterGenerationSuccess({
    required this.content,
    required this.status,
  });

  @override
  List<Object?> get props => [content, status];
}

/// State when AI cover letter generation fails
class CoverLetterGenerationFailure extends ApplyState {
  /// Error message
  final String message;

  /// Constructor
  const CoverLetterGenerationFailure(this.message);

  @override
  List<Object?> get props => [message];
}
