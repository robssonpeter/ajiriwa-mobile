import 'package:equatable/equatable.dart';

import '../../domain/entities/jobs_response.dart';
import 'job_listing_model.dart';

/// Jobs response model for the jobs list
class JobsResponseModel extends Equatable {
  /// List of jobs
  final List<JobListingModel> jobs;

  /// List of sponsored jobs
  final List<JobListingModel> sponsoredJobs;

  /// Current page
  final int page;

  /// Number of jobs per page
  final int perPage;

  /// Total number of jobs
  final int total;

  /// Whether there are more jobs to load
  final bool hasMore;

  /// Constructor
  const JobsResponseModel({
    required this.jobs,
    required this.sponsoredJobs,
    required this.page,
    required this.perPage,
    required this.total,
    required this.hasMore,
  });

  /// Create a jobs response model from JSON
  factory JobsResponseModel.fromJson(Map<String, dynamic> json) {
    return JobsResponseModel(
      jobs: (json['data'] as List)
          .map((job) => JobListingModel.fromJson(job as Map<String, dynamic>))
          .toList(),
      sponsoredJobs: (json['sponsored_jobs'] as List)
          .map((job) => JobListingModel.fromJson(job as Map<String, dynamic>))
          .toList(),
      page: json['meta']['page'] as int,
      perPage: json['meta']['per_page'] as int,
      total: json['meta']['total'] as int,
      hasMore: json['meta']['has_more'] as bool,
    );
  }

  /// Convert model to entity
  JobsResponse toEntity() {
    return JobsResponse(
      jobs: jobs.map((job) => job.toEntity()).toList(),
      sponsoredJobs: sponsoredJobs.map((job) => job.toEntity()).toList(),
      page: page,
      perPage: perPage,
      total: total,
      hasMore: hasMore,
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