import 'package:equatable/equatable.dart';

import '../../domain/entities/job_listing.dart';

/// Job listing model for the jobs list
class JobListingModel extends Equatable {
  /// Job ID
  final int id;

  /// Job slug for URL
  final String slug;

  /// Job title
  final String title;

  /// Company name
  final String? companyName;

  /// Job location
  final String location;

  /// Job type (e.g., Full-Time)
  final String jobType;

  /// Posted time ago text (e.g., "2 days ago")
  final String postedTimeago;

  /// Company logo URL
  final String? companyLogoUrl;

  /// Whether the user has applied for this job
  final bool isApplied;

  /// Whether the user has saved this job
  final bool isSaved;

  /// Constructor
  const JobListingModel({
    required this.id,
    required this.slug,
    required this.title,
    this.companyName,
    required this.location,
    required this.jobType,
    required this.postedTimeago,
    this.companyLogoUrl,
    required this.isApplied,
    required this.isSaved,
  });

  /// Create a job listing model from JSON
  factory JobListingModel.fromJson(Map<String, dynamic> json) {
    return JobListingModel(
      id: json['id'] as int,
      slug: json['slug'] as String,
      title: json['title'] as String,
      companyName: json['company_name'] as String?,
      location: json['location'] as String,
      jobType: json['job_type'] as String,
      postedTimeago: json['posted_timeago'] as String,
      companyLogoUrl: json['company_logo_url'] as String?,
      isApplied: (json['is_applied'] as bool?) ?? false,
      isSaved: (json['is_saved'] as bool?) ?? false,
    );
  }

  /// Convert model to entity
  JobListing toEntity() {
    return JobListing(
      id: id,
      slug: slug,
      title: title,
      companyName: companyName,
      location: location,
      jobType: jobType,
      postedTimeago: postedTimeago,
      companyLogoUrl: companyLogoUrl,
      isApplied: isApplied,
      isSaved: isSaved,
    );
  }

  @override
  List<Object?> get props => [
        id,
        slug,
        title,
        companyName,
        location,
        jobType,
        postedTimeago,
        companyLogoUrl,
        isApplied,
        isSaved,
      ];
}
