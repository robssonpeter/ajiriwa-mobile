import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/jobs/domain/repositories/job_repository.dart';
import 'saved_jobs_event.dart';
import 'saved_jobs_state.dart';

/// Bloc for managing saved jobs
class SavedJobsBloc extends Bloc<SavedJobsEvent, SavedJobsState> {
  /// Job repository
  final JobRepository jobRepository;

  /// Constructor
  SavedJobsBloc({required this.jobRepository}) : super(SavedJobsInitial()) {
    on<LoadSavedJobsEvent>(_onLoadSavedJobs);
    on<RemoveFromSavedJobsEvent>(_onRemoveFromSavedJobs);
  }

  /// Handle load saved jobs event
  Future<void> _onLoadSavedJobs(
    LoadSavedJobsEvent event,
    Emitter<SavedJobsState> emit,
  ) async {
    emit(SavedJobsLoading());

    final result = await jobRepository.getSavedJobs();

    result.fold(
      (failure) => emit(SavedJobsError(message: failure.toString())),
      (savedJobs) => emit(SavedJobsLoaded(savedJobs: savedJobs)),
    );
  }

  /// Handle remove from saved jobs event
  Future<void> _onRemoveFromSavedJobs(
    RemoveFromSavedJobsEvent event,
    Emitter<SavedJobsState> emit,
  ) async {
    // TODO: Implement remove from saved jobs functionality
    // This would require adding a method to the JobRepository
    // For now, just reload the saved jobs
    add(LoadSavedJobsEvent());
  }
}
