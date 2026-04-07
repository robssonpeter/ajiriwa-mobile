import 'package:equatable/equatable.dart';

/// Dashboard entity representing the dashboard data
class Dashboard extends Equatable {
  /// Profile completion information
  final ProfileCompletion profileCompletion;

  /// List of recommended jobs
  final List<RecommendedJob> recommendedJobs;

  /// List of recent applications
  final List<RecentApplication> recentApplications;

  /// Auto-apply settings
  final AutoApplySettings? autoApplySettings;

  /// Job match count
  final int jobMatchCount;

  /// Auto-applied count
  final int autoAppliedCount;

  /// Total applications count (all time)
  final int totalApplicationsCount;

  /// Unread notifications count
  final int unreadNotificationsCount;

  /// Constructor
  const Dashboard({
    required this.profileCompletion,
    required this.recommendedJobs,
    required this.recentApplications,
    this.autoApplySettings,
    required this.jobMatchCount,
    required this.autoAppliedCount,
    required this.totalApplicationsCount,
    required this.unreadNotificationsCount,
  });

  @override
  List<Object?> get props => [
        profileCompletion,
        recommendedJobs,
        recentApplications,
        autoApplySettings,
        jobMatchCount,
        autoAppliedCount,
        totalApplicationsCount,
        unreadNotificationsCount,
      ];
}

/// Auto-apply settings entity
class AutoApplySettings extends Equatable {
  /// Whether auto-apply is enabled
  final bool enabled;

  /// Constructor
  const AutoApplySettings({
    required this.enabled,
  });

  @override
  List<Object?> get props => [enabled];
}

/// Profile completion entity
class ProfileCompletion extends Equatable {
  /// Completion percentage (0-100)
  final int percentage;

  /// List of missing sections
  final List<String> missingSections;

  /// Constructor
  const ProfileCompletion({
    required this.percentage,
    required this.missingSections,
  });

  @override
  List<Object?> get props => [percentage, missingSections];
}

/// Company entity for jobs
class Company extends Equatable {
  /// Company ID
  final int id;

  /// Company name
  final String name;

  /// Company logo URL
  final String? logo;

  /// Company logo URL (alternative field)
  final String? logoUrl;

  /// Constructor
  const Company({
    required this.id,
    required this.name,
    this.logo,
    this.logoUrl,
  });

  /// Get the effective logo URL (logoUrl if available, otherwise logo)
  String? get effectiveLogoUrl => logoUrl ?? logo;

  @override
  List<Object?> get props => [id, name, logo, logoUrl];
}

/// Recommended job entity
class RecommendedJob extends Equatable {
  /// Job ID
  final int id;

  /// Job title
  final String title;

  /// Job location
  final String location;

  /// Minimum salary
  final int? minSalary;

  /// Maximum salary
  final int? maxSalary;

  /// Job type (e.g., Full-time)
  final String type;

  /// Application deadline
  final String deadline;

  /// Whether the user has applied for this job
  final bool isApplied;

  /// Whether the user has saved this job
  final bool isSaved;

  /// Job slug for URL
  final String? slug;

  /// Date the job was posted (YYYY-MM-DD)
  final String? postedAt;

  /// Company information
  final Company company;

  /// Constructor
  const RecommendedJob({
    required this.id,
    required this.title,
    required this.location,
    this.minSalary,
    this.maxSalary,
    required this.type,
    required this.deadline,
    required this.isApplied,
    required this.isSaved,
    this.slug,
    this.postedAt,
    required this.company,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        location,
        minSalary,
        maxSalary,
        type,
        deadline,
        isApplied,
        isSaved,
        slug,
        postedAt,
        company,
      ];
}

/// Job entity for applications
class Job extends Equatable {
  /// Job ID
  final int id;

  /// Job title
  final String title;

  /// Job location
  final String location;

  /// Application deadline
  final String deadline;

  /// Company information
  final Company company;

  /// Constructor
  const Job({
    required this.id,
    required this.title,
    required this.location,
    required this.deadline,
    required this.company,
  });

  @override
  List<Object?> get props => [id, title, location, deadline, company];
}

/// Recent application entity
class RecentApplication extends Equatable {
  /// Application ID
  final int id;

  /// Application status (1: submitted, 2: review, 3: rejected, 4: accepted)
  final int status;

  /// Application date
  final String appliedAt;

  /// Job information (can be null)
  final Job? job;

  /// Constructor
  const RecentApplication({
    required this.id,
    required this.status,
    required this.appliedAt,
    this.job,
  });

  @override
  List<Object?> get props => [id, status, appliedAt, job];
}
