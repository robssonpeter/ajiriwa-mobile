import 'package:equatable/equatable.dart';

/// Job listing entity for the jobs list
class JobListing extends Equatable {
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
  const JobListing({
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
