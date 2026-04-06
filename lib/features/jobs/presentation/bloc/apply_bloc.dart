import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/job_repository.dart';
import 'apply_event.dart';
import 'apply_state.dart';

/// Apply bloc
class ApplyBloc extends Bloc<ApplyEvent, ApplyState> {
  /// Job repository
  final JobRepository jobRepository;

  /// Constructor
  ApplyBloc({required this.jobRepository}) : super(ApplyInitial()) {
    on<ApplyEligibilityRequested>(_onApplyEligibilityRequested);
    on<ApplyStarted>(_onApplyStarted);
    on<ApplyScreeningLoaded>(_onApplyScreeningLoaded);
    on<ApplySubmitted>(_onApplySubmitted);
    on<ApplyExternalIntentRecorded>(_onApplyExternalIntentRecorded);
    on<ApplyExternalMarkedAsApplied>(_onApplyExternalMarkedAsApplied);
    on<ApplyExternalClickRecorded>(_onApplyExternalClickRecorded);
    on<ApplyReset>(_onApplyReset);
    on<ApplyContextRequested>(_onApplyContextRequested);
    on<CandidatesRequested>(_onCandidatesRequested);
    on<CandidateCreated>(_onCandidateCreated);
    on<CandidateSelected>(_onCandidateSelected);
  }

  /// Handle apply eligibility requested event
  Future<void> _onApplyEligibilityRequested(
    ApplyEligibilityRequested event,
    Emitter<ApplyState> emit,
  ) async {
    print('ApplyBloc._onApplyEligibilityRequested called with jobId: ${event.jobId}, candidateId: ${event.candidateId}');
    emit(ApplyCheckingEligibility());
    try {
      print('Calling jobRepository.checkJobEligibility');
      final result = await jobRepository.checkJobEligibility(event.jobId, candidateId: event.candidateId);
      print('Result from jobRepository.checkJobEligibility: $result');
      result.fold(
        (failure) {
          print('Failure from jobRepository.checkJobEligibility: $failure');
          print('Failure type: ${failure.runtimeType}');
          print('Failure message: ${failure.toString()}');
          emit(ApplyFailure(message: failure.toString()));
        },
        (eligibility) {
          print('Eligibility from jobRepository.checkJobEligibility: $eligibility');
          print('Eligible: ${eligibility.eligible}');
          print('Has external URL: ${eligibility.hasExternalUrl}');
          print('Has instruction in description: ${eligibility.hasInstructionInDescription}');

          emit(ApplyEligibilityReady(
            eligible: eligibility.eligible,
            details: eligibility,
          ));

          // If eligible, determine the next flow based on application method
          if (eligibility.eligible) {
            // Check if screening is required
            if (eligibility.screeningRequired) {
              print('Screening required, loading screening questions for job ID: ${event.jobId}');
              // Load screening questions first
              add(ApplyScreeningLoaded(event.jobId));
            } else {
              // No screening required, proceed with normal flow
              switch (eligibility.applicationMethod) {
                case 'url':
                  print('Emitting ApplyFlowRequired with mode: external_url');
                  emit(ApplyFlowRequired(mode: 'external_url'));
                  break;
                case 'description':
                  print('Emitting ApplyFlowRequired with mode: instructions');
                  emit(ApplyFlowRequired(mode: 'instructions'));
                  break;
                case 'email':
                  print('Emitting ApplyFlowRequired with mode: email');
                  emit(ApplyFlowRequired(mode: 'email'));
                  break;
                case 'ajiriwa':
                default:
                  print('Emitting ApplyFlowRequired with mode: ajiriwa');
                  emit(ApplyFlowRequired(mode: 'ajiriwa'));
                  break;
              }
            }
          } else {
            print('Not eligible to apply');
          }
        },
      );
    } catch (e) {
      print('Unexpected error in ApplyBloc._onApplyEligibilityRequested: $e');
      print('Error type: ${e.runtimeType}');
      emit(ApplyFailure(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  /// Handle apply started event
  Future<void> _onApplyStarted(
    ApplyStarted event,
    Emitter<ApplyState> emit,
  ) async {
    // This event is used to explicitly start a specific apply flow
    if (event.mode == 'ajiriwa') {
      add(ApplyScreeningLoaded(event.jobId));
    } else {
      emit(ApplyFlowRequired(mode: event.mode));
    }
  }

  /// Handle apply screening loaded event
  Future<void> _onApplyScreeningLoaded(
    ApplyScreeningLoaded event,
    Emitter<ApplyState> emit,
  ) async {
    final result = await jobRepository.getJobScreening(event.jobId);
    result.fold(
      (failure) => emit(ApplyFailure(message: failure.toString())),
      (screening) {
        // Get the current eligibility state to determine the application method
        final currentState = state;
        String mode = 'ajiriwa'; // Default mode

        // If we have eligibility information, use the application method from there
        if (currentState is ApplyEligibilityReady) {
          mode = currentState.details.applicationMethod;
        }

        emit(ApplyFlowRequired(
          mode: mode,
          screening: screening,
        ));
      },
    );
  }

  /// Handle apply submitted event
  Future<void> _onApplySubmitted(
    ApplySubmitted event,
    Emitter<ApplyState> emit,
  ) async {
    emit(ApplySubmitting());
    final result = await jobRepository.applyForJob(
      jobId: event.jobId,
      screeningAnswers: event.screeningAnswers,
      resumeId: event.resumeId,
      coverLetter: event.coverLetter,
      attachments: event.attachments,
      candidateId: event.candidateId,
    );
    result.fold(
      (failure) => emit(ApplyFailure(
        message: failure.toString(),
        // Preserve form data when validation errors occur
        details: {
          'jobId': event.jobId,
          'screeningAnswers': event.screeningAnswers,
          'resumeId': event.resumeId,
          'coverLetter': event.coverLetter,
          'attachments': event.attachments,
          'candidateId': event.candidateId,
        },
      )),
      (response) => emit(ApplySuccess(
        applicationId: response.applicationId,
        mode: 'ajiriwa',
      )),
    );
  }

  /// Handle apply external intent recorded event
  Future<void> _onApplyExternalIntentRecorded(
    ApplyExternalIntentRecorded event,
    Emitter<ApplyState> emit,
  ) async {
    emit(ApplySubmitting());
    final result = await jobRepository.recordApplyIntent(
      jobId: event.jobId,
      mode: event.mode,
      notes: event.notes,
      candidateId: event.candidateId,
    );
    result.fold(
      (failure) => emit(ApplyFailure(message: failure.toString())),
      (response) {
        // Only emit ApplyExternalIntentRecordedState for URL applications
        // This prevents the success dialog from showing prematurely
        if (event.mode == 'external_url') {
          emit(ApplyExternalIntentRecordedState(response));
        } else {
          // For non-URL applications, emit ApplySuccess if applicationId is not null
          emit(ApplyExternalIntentRecordedState(response));
          if (response.applicationId != null) {
            emit(ApplySuccess(
              applicationId: response.applicationId!,
              mode: event.mode,
            ));
          }
        }
      },
    );
  }

  /// Handle apply external marked as applied event
  Future<void> _onApplyExternalMarkedAsApplied(
    ApplyExternalMarkedAsApplied event,
    Emitter<ApplyState> emit,
  ) async {
    emit(ApplySubmitting());
    final result = await jobRepository.markExternalApplicationAsApplied(event.applicationId);
    result.fold(
      (failure) => emit(ApplyFailure(message: failure.toString())),
      (_) {
        // Emit both states: first the marked as applied state, then the success state
        emit(ApplyExternalMarkedAsAppliedState(event.applicationId));
        // Also emit ApplySuccess to show the success dialog
        emit(ApplySuccess(
          applicationId: event.applicationId,
          mode: 'external_url',
        ));
      },
    );
  }

  /// Handle apply reset event
  void _onApplyReset(
    ApplyReset event,
    Emitter<ApplyState> emit,
  ) {
    emit(ApplyInitial());
  }

  /// Handle apply external click recorded event
  Future<void> _onApplyExternalClickRecorded(
    ApplyExternalClickRecorded event,
    Emitter<ApplyState> emit,
  ) async {
    // We don't need to emit any state for this event
    // Just record the click in the backend
    await jobRepository.recordExternalClick(event.jobId, candidateId: event.candidateId);
  }

  /// Handle apply context requested event
  Future<void> _onApplyContextRequested(
    ApplyContextRequested event,
    Emitter<ApplyState> emit,
  ) async {
    emit(ApplySubmitting());
    final result = await jobRepository.getApplyContextBySlug(event.slug, candidateId: event.candidateId);
    result.fold(
      (failure) => emit(ApplyFailure(message: failure.toString())),
      (applyContext) => emit(ApplyContextLoaded(applyContext)),
    );
  }

  /// Handle candidates requested event
  Future<void> _onCandidatesRequested(
    CandidatesRequested event,
    Emitter<ApplyState> emit,
  ) async {
    emit(CandidatesLoading());
    final result = await jobRepository.getCandidates();
    result.fold(
      (failure) => emit(ApplyFailure(message: failure.toString())),
      (candidates) {
        // Extract selectedCandidateId from the response if available
        final selectedCandidateId = candidates['selectedCandidateId'] as int?;
        emit(CandidatesLoaded(candidates, selectedCandidateId: selectedCandidateId));
      },
    );
  }

  /// Handle candidate created event
  Future<void> _onCandidateCreated(
    CandidateCreated event,
    Emitter<ApplyState> emit,
  ) async {
    emit(CandidateCreating());
    final result = await jobRepository.createCandidate(event.professionalTitle);
    result.fold(
      (failure) => emit(ApplyFailure(message: failure.toString())),
      (candidate) => emit(CandidateCreatedState(candidate)),
    );
  }

  /// Handle candidate selected event
  void _onCandidateSelected(
    CandidateSelected event,
    Emitter<ApplyState> emit,
  ) {
    // If we have a current state with candidates, update it with the selected candidate
    final currentState = state;
    if (currentState is CandidatesLoaded) {
      emit(CandidatesLoaded(currentState.candidates, selectedCandidateId: event.candidateId));
    }
    // Otherwise, we just store the selection and wait for candidates to be loaded
  }
}
