import 'package:equatable/equatable.dart';

/// Dashboard model representing the dashboard data from the API
class DashboardModel extends Equatable {
  /// Profile completion information
  final ProfileCompletionModel profileCompletion;

  /// List of recommended jobs
  final List<RecommendedJobModel> recommendedJobs;

  /// List of recent applications
  final List<RecentApplicationModel> recentApplications;

  /// Auto-apply settings
  final AutoApplySettingsModel? autoApplySettings;

  /// Job match count
  final int jobMatchCount;

  /// Auto-applied count
  final int autoAppliedCount;

  /// Total applications count (all time)
  final int totalApplicationsCount;

  /// Unread notifications count
  final int unreadNotificationsCount;

  /// Constructor
  const DashboardModel({
    required this.profileCompletion,
    required this.recommendedJobs,
    required this.recentApplications,
    this.autoApplySettings,
    required this.jobMatchCount,
    required this.autoAppliedCount,
    required this.totalApplicationsCount,
    required this.unreadNotificationsCount,
  });

  /// Create a dashboard model from JSON
  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      profileCompletion: ProfileCompletionModel.fromJson(
        json['profile_completion'] as Map<String, dynamic>,
      ),
      recommendedJobs: (json['recommended_jobs'] as List)
          .map((job) => RecommendedJobModel.fromJson(job as Map<String, dynamic>))
          .toList(),
      recentApplications: (json['recent_applications'] as List)
          .map((app) => RecentApplicationModel.fromJson(app as Map<String, dynamic>))
          .toList(),
      autoApplySettings: json['auto_apply_settings'] != null
          ? AutoApplySettingsModel.fromJson(json['auto_apply_settings'] as Map<String, dynamic>)
          : null,
      jobMatchCount: json['job_match_count'] as int? ?? 0,
      autoAppliedCount: json['auto_applied_count'] as int? ?? 0,
      totalApplicationsCount: json['total_applications_count'] as int? ?? 0,
      unreadNotificationsCount: json['unread_notifications_count'] as int? ?? 0,
    );
  }

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

/// Auto-apply settings model
class AutoApplySettingsModel extends Equatable {
  /// Whether auto-apply is enabled
  final bool enabled;

  /// Constructor
  const AutoApplySettingsModel({
    required this.enabled,
  });

  /// Create an auto-apply settings model from JSON
  factory AutoApplySettingsModel.fromJson(Map<String, dynamic> json) {
    return AutoApplySettingsModel(
      enabled: json['enabled'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [enabled];
}

/// Profile completion model
class ProfileCompletionModel extends Equatable {
  /// Completion percentage (0-100)
  final int percentage;

  /// List of missing sections
  final List<String> missingSections;

  /// Constructor
  const ProfileCompletionModel({
    required this.percentage,
    required this.missingSections,
  });

  /// Create a profile completion model from JSON
  factory ProfileCompletionModel.fromJson(Map<String, dynamic> json) {
    return ProfileCompletionModel(
      percentage: json['percentage'] as int,
      missingSections: (json['missing_sections'] as List)
          .map((section) => section as String)
          .toList(),
    );
  }

  @override
  List<Object?> get props => [percentage, missingSections];
}

/// Company model for jobs
class CompanyModel extends Equatable {
  /// Company ID
  final int id;

  /// Company name
  final String name;

  /// Company logo URL
  final String? logo;

  /// Company logo URL (alternative field)
  final String? logoUrl;

  /// Constructor
  const CompanyModel({
    required this.id,
    required this.name,
    this.logo,
    this.logoUrl,
  });

  /// Create a company model from JSON
  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as int,
      name: json['name'] as String,
      logo: json['logo'] as String?,
      logoUrl: json['logo_url'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, logo, logoUrl];
}

/// Recommended job model
class RecommendedJobModel extends Equatable {
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
  final CompanyModel company;

  /// Constructor
  const RecommendedJobModel({
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

  /// Create a recommended job model from JSON
  factory RecommendedJobModel.fromJson(Map<String, dynamic> json) {
    return RecommendedJobModel(
      id: json['id'] as int,
      title: json['title'] as String,
      location: json['location'] as String? ?? '',
      minSalary: json['min_salary'] as int?,
      maxSalary: json['max_salary'] as int?,
      type: json['type'] as String? ?? '',
      deadline: json['deadline'] as String? ?? '',
      isApplied: json['is_applied'] as bool? ?? false,
      isSaved: json['is_saved'] as bool? ?? false,
      slug: json['slug'] as String?,
      postedAt: json['posted_at'] as String?,
      company: CompanyModel.fromJson(json['company'] as Map<String, dynamic>),
    );
  }

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

/// Job model for applications
class JobModel extends Equatable {
  /// Job ID
  final int id;

  /// Job title
  final String title;

  /// Job location
  final String location;

  /// Application deadline
  final String deadline;

  /// Company information
  final CompanyModel company;

  /// Constructor
  const JobModel({
    required this.id,
    required this.title,
    required this.location,
    required this.deadline,
    required this.company,
  });

  /// Create a job model from JSON
  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] as int,
      title: json['title'] as String,
      location: json['location'] as String,
      deadline: json['deadline'] as String,
      company: CompanyModel.fromJson(json['company'] as Map<String, dynamic>),
    );
  }

  @override
  List<Object?> get props => [id, title, location, deadline, company];
}

/// Recent application model
class RecentApplicationModel extends Equatable {
  /// Application ID
  final int id;

  /// Application status (1: submitted, 2: review, 3: rejected, 4: accepted)
  final int status;

  /// Application date
  final String appliedAt;

  /// Job information (can be null)
  final JobModel? job;

  /// Constructor
  const RecentApplicationModel({
    required this.id,
    required this.status,
    required this.appliedAt,
    this.job,
  });

  /// Create a recent application model from JSON
  factory RecentApplicationModel.fromJson(Map<String, dynamic> json) {
    return RecentApplicationModel(
      id: json['id'] as int,
      status: json['status'] as int,
      appliedAt: json['applied_at'] as String,
      job: json['job'] != null 
          ? JobModel.fromJson(json['job'] as Map<String, dynamic>) 
          : null,
    );
  }

  @override
  List<Object?> get props => [id, status, appliedAt, job];
}
