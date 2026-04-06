import 'package:equatable/equatable.dart';

/// Base class for all jobs events
abstract class JobsEvent extends Equatable {
  /// Constructor
  const JobsEvent();

  @override
  List<Object?> get props => [];
}

/// Load jobs event
class LoadJobsEvent extends JobsEvent {
  /// Search query
  final String? query;

  /// Job location
  final String? location;

  /// Job type
  final String? jobType;

  /// Job category
  final int? category;

  /// Company industry
  final int? industry;

  /// Minimum salary
  final int? minSalary;

  /// Maximum salary
  final int? maxSalary;

  /// Constructor
  const LoadJobsEvent({
    this.query,
    this.location,
    this.jobType,
    this.category,
    this.industry,
    this.minSalary,
    this.maxSalary,
  });

  @override
  List<Object?> get props => [
        query,
        location,
        jobType,
        category,
        industry,
        minSalary,
        maxSalary,
      ];
}

/// Load more jobs event (pagination)
class LoadMoreJobsEvent extends JobsEvent {}

/// Apply filters event
class ApplyFiltersEvent extends JobsEvent {
  /// Search query
  final String? query;

  /// Job location
  final String? location;

  /// Job type
  final String? jobType;

  /// Job category
  final int? category;

  /// Company industry
  final int? industry;

  /// Minimum salary
  final int? minSalary;

  /// Maximum salary
  final int? maxSalary;

  /// Constructor
  const ApplyFiltersEvent({
    this.query,
    this.location,
    this.jobType,
    this.category,
    this.industry,
    this.minSalary,
    this.maxSalary,
  });

  @override
  List<Object?> get props => [
        query,
        location,
        jobType,
        category,
        industry,
        minSalary,
        maxSalary,
      ];
}

/// Clear filters event
class ClearFiltersEvent extends JobsEvent {}

/// Toggle job saved status event
class ToggleJobSavedEvent extends JobsEvent {
  /// Job ID
  final int jobId;

  /// Current saved status
  final bool isSaved;

  /// Constructor
  const ToggleJobSavedEvent({
    required this.jobId,
    required this.isSaved,
  });

  @override
  List<Object?> get props => [jobId, isSaved];
}
