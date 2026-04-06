import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/job_repository.dart';
import 'job_event.dart';
import 'job_state.dart';

/// Job bloc
class JobBloc extends Bloc<JobEvent, JobState> {
  /// Job repository
  final JobRepository jobRepository;

  /// Constructor
  JobBloc({required this.jobRepository}) : super(JobInitial()) {
    on<LoadJobDetailsEvent>(_onLoadJobDetails);
    on<ToggleJobSavedEvent>(_onToggleJobSaved);
  }

  /// Handle load job details event
  Future<void> _onLoadJobDetails(
    LoadJobDetailsEvent event,
    Emitter<JobState> emit,
  ) async {
    emit(JobLoading());
    final result = await jobRepository.getJobDetails(event.slug);
    result.fold(
      (failure) => emit(JobError(failure.toString())),
      (jobDetails) => emit(JobLoaded(jobDetails)),
    );
  }

  /// Handle toggle job saved event
  Future<void> _onToggleJobSaved(
    ToggleJobSavedEvent event,
    Emitter<JobState> emit,
  ) async {
    // Store the current state to restore it later if needed
    final currentState = state;
    if (currentState is! JobLoaded) {
      // Can only toggle saved status if job details are loaded
      return;
    }

    // Emit saving/unsaving state
    if (event.isSaved) {
      emit(JobUnsavingState(currentState.jobDetails));
    } else {
      emit(JobSavingState(currentState.jobDetails));
    }

    // Call the appropriate repository method
    final result = event.isSaved
        ? await jobRepository.unsaveJob(event.jobId)
        : await jobRepository.saveJob(event.jobId);

    result.fold(
      (failure) {
        // Emit error state
        emit(JobSaveErrorState(
          message: failure.toString(),
          jobId: event.jobId,
          wasSaving: !event.isSaved,
        ));

        // Restore previous state
        emit(currentState);
      },
      (_) {
        // Create a new job details object with the updated isSaved status
        final updatedJobDetails = currentState.jobDetails.copyWith(
          isSaved: !event.isSaved, // Toggle the saved status
        );

        // Emit success state
        if (event.isSaved) {
          emit(JobUnsavedSuccessState(
            jobId: event.jobId,
            jobTitle: currentState.jobDetails.title,
          ));
        } else {
          emit(JobSavedSuccessState(
            jobId: event.jobId,
            jobTitle: currentState.jobDetails.title,
          ));
        }

        // Emit updated state
        emit(JobLoaded(updatedJobDetails));
      },
    );
  }
}
