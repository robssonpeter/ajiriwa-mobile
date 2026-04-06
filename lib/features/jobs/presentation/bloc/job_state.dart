import 'package:equatable/equatable.dart';

import '../../domain/entities/job_details.dart';

/// Base class for all job states
abstract class JobState extends Equatable {
  /// Constructor
  const JobState();

  @override
  List<Object?> get props => [];
}

/// Initial job state
class JobInitial extends JobState {}

/// Loading job details state
class JobLoading extends JobState {}

/// Loaded job details state
class JobLoaded extends JobState {
  /// Job details
  final JobDetails jobDetails;

  /// Constructor
  const JobLoaded(this.jobDetails);

  /// Create a copy of this JobLoaded state with the given fields replaced with the new values
  JobLoaded copyWith({
    JobDetails? jobDetails,
  }) {
    return JobLoaded(
      jobDetails ?? this.jobDetails,
    );
  }

  @override
  List<Object?> get props => [jobDetails];
}

/// Job error state
class JobError extends JobState {
  /// Error message
  final String message;

  /// Constructor
  const JobError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Job saving state
class JobSavingState extends JobLoaded {
  /// Constructor
  const JobSavingState(JobDetails jobDetails) : super(jobDetails);

  @override
  List<Object?> get props => [jobDetails, 'saving'];
}

/// Job unsaving state
class JobUnsavingState extends JobLoaded {
  /// Constructor
  const JobUnsavingState(JobDetails jobDetails) : super(jobDetails);

  @override
  List<Object?> get props => [jobDetails, 'unsaving'];
}

/// Job save error state
class JobSaveErrorState extends JobState {
  /// Error message
  final String message;

  /// Job ID that failed to save/unsave
  final int jobId;

  /// Whether the operation was a save (true) or unsave (false)
  final bool wasSaving;

  /// Constructor
  const JobSaveErrorState({
    required this.message,
    required this.jobId,
    required this.wasSaving,
  });

  @override
  List<Object?> get props => [message, jobId, wasSaving];
}

/// Job saved success state
class JobSavedSuccessState extends JobState {
  /// Job ID that was saved
  final int jobId;

  /// Job title
  final String jobTitle;

  /// Constructor
  const JobSavedSuccessState({
    required this.jobId,
    required this.jobTitle,
  });

  @override
  List<Object?> get props => [jobId, jobTitle];
}

/// Job unsaved success state
class JobUnsavedSuccessState extends JobState {
  /// Job ID that was unsaved
  final int jobId;

  /// Job title
  final String jobTitle;

  /// Constructor
  const JobUnsavedSuccessState({
    required this.jobId,
    required this.jobTitle,
  });

  @override
  List<Object?> get props => [jobId, jobTitle];
}
