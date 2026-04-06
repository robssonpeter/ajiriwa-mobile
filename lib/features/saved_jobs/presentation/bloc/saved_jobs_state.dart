import 'package:equatable/equatable.dart';

import '../../../../features/jobs/domain/entities/job_details.dart';

/// Base class for all saved jobs states
abstract class SavedJobsState extends Equatable {
  /// Constructor
  const SavedJobsState();

  @override
  List<Object?> get props => [];
}

/// Initial saved jobs state
class SavedJobsInitial extends SavedJobsState {}

/// Loading saved jobs state
class SavedJobsLoading extends SavedJobsState {}

/// Loaded saved jobs state
class SavedJobsLoaded extends SavedJobsState {
  /// List of saved jobs
  final List<JobDetails> savedJobs;

  /// Constructor
  const SavedJobsLoaded({required this.savedJobs});

  @override
  List<Object?> get props => [savedJobs];
}

/// Error saved jobs state
class SavedJobsError extends SavedJobsState {
  /// Error message
  final String message;

  /// Constructor
  const SavedJobsError({required this.message});

  @override
  List<Object?> get props => [message];
}