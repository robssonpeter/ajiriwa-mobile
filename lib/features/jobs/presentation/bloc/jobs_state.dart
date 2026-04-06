import 'package:equatable/equatable.dart';

import '../../domain/entities/job_listing.dart';
import '../../domain/entities/jobs_response.dart';

/// Base class for all jobs states
abstract class JobsState extends Equatable {
  /// Constructor
  const JobsState();

  @override
  List<Object?> get props => [];
}

/// Initial jobs state
class JobsInitial extends JobsState {}

/// Loading jobs state
class JobsLoading extends JobsState {
  /// Whether this is the initial load or a pagination load
  final bool isInitialLoad;

  /// Constructor
  const JobsLoading({this.isInitialLoad = true});

  @override
  List<Object?> get props => [isInitialLoad];
}

/// Loaded jobs state
class JobsLoaded extends JobsState {
  /// List of jobs
  final List<JobListing> jobs;

  /// List of sponsored jobs
  final List<JobListing> sponsoredJobs;

  /// Current page
  final int page;

  /// Number of jobs per page
  final int perPage;

  /// Total number of jobs
  final int total;

  /// Whether there are more jobs to load
  final bool hasMore;

  /// Current filters
  final Map<String, dynamic> filters;

  /// Constructor
  const JobsLoaded({
    required this.jobs,
    required this.sponsoredJobs,
    required this.page,
    required this.perPage,
    required this.total,
    required this.hasMore,
    this.filters = const {},
  });

  /// Create a copy of this JobsLoaded state with the given fields replaced with the new values
  JobsLoaded copyWith({
    List<JobListing>? jobs,
    List<JobListing>? sponsoredJobs,
    int? page,
    int? perPage,
    int? total,
    bool? hasMore,
    Map<String, dynamic>? filters,
  }) {
    return JobsLoaded(
      jobs: jobs ?? this.jobs,
      sponsoredJobs: sponsoredJobs ?? this.sponsoredJobs,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      filters: filters ?? this.filters,
    );
  }

  /// Create a JobsLoaded state from a JobsResponse entity
  factory JobsLoaded.fromJobsResponse(
    JobsResponse response, {
    Map<String, dynamic> filters = const {},
  }) {
    return JobsLoaded(
      jobs: response.jobs,
      sponsoredJobs: response.sponsoredJobs,
      page: response.page,
      perPage: response.perPage,
      total: response.total,
      hasMore: response.hasMore,
      filters: filters,
    );
  }

  @override
  List<Object?> get props => [
        jobs,
        sponsoredJobs,
        page,
        perPage,
        total,
        hasMore,
        filters,
      ];
}

/// Loading more jobs state (extends JobsLoaded to preserve the current jobs list)
class JobsLoadingMore extends JobsLoaded {
  /// Constructor
  const JobsLoadingMore({
    required super.jobs,
    required super.sponsoredJobs,
    required super.page,
    required super.perPage,
    required super.total,
    required super.hasMore,
    super.filters = const {},
  });

  @override
  List<Object?> get props => [
        jobs,
        sponsoredJobs,
        page,
        perPage,
        total,
        hasMore,
        filters,
        'loading_more', // Add this to distinguish from JobsLoaded
      ];
}

/// Jobs error state
class JobsError extends JobsState {
  /// Error message
  final String message;

  /// Constructor
  const JobsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Job saving state
class JobSavingState extends JobsLoaded {
  /// Job ID being saved
  final int jobId;

  /// Constructor
  const JobSavingState({
    required this.jobId,
    required super.jobs,
    required super.sponsoredJobs,
    required super.page,
    required super.perPage,
    required super.total,
    required super.hasMore,
    super.filters = const {},
  });

  @override
  List<Object?> get props => [
    jobs,
    sponsoredJobs,
    page,
    perPage,
    total,
    hasMore,
    filters,
    jobId,
    'saving', // Add this to distinguish from JobsLoaded
  ];
}

/// Job unsaving state
class JobUnsavingState extends JobsLoaded {
  /// Job ID being unsaved
  final int jobId;

  /// Constructor
  const JobUnsavingState({
    required this.jobId,
    required super.jobs,
    required super.sponsoredJobs,
    required super.page,
    required super.perPage,
    required super.total,
    required super.hasMore,
    super.filters = const {},
  });

  @override
  List<Object?> get props => [
    jobs,
    sponsoredJobs,
    page,
    perPage,
    total,
    hasMore,
    filters,
    jobId,
    'unsaving', // Add this to distinguish from JobsLoaded
  ];
}

/// Job save error state
class JobSaveErrorState extends JobsState {
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
class JobSavedSuccessState extends JobsState {
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
class JobUnsavedSuccessState extends JobsState {
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
