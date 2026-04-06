import 'package:equatable/equatable.dart';

import 'job_listing.dart';

/// Jobs response entity for the jobs list
class JobsResponse extends Equatable {
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

  /// Constructor
  const JobsResponse({
    required this.jobs,
    required this.sponsoredJobs,
    required this.page,
    required this.perPage,
    required this.total,
    required this.hasMore,
  });

  /// Create a copy of this JobsResponse with the given fields replaced with the new values
  JobsResponse copyWith({
    List<JobListing>? jobs,
    List<JobListing>? sponsoredJobs,
    int? page,
    int? perPage,
    int? total,
    bool? hasMore,
  }) {
    return JobsResponse(
      jobs: jobs ?? this.jobs,
      sponsoredJobs: sponsoredJobs ?? this.sponsoredJobs,
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
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
      ];
}