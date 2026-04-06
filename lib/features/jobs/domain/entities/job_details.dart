import 'package:equatable/equatable.dart';

import '../../../../../features/dashboard/domain/entities/dashboard.dart';

/// Job details entity
class JobDetails extends Equatable {
  /// Job ID
  final int id;

  /// Job title
  final String title;

  /// Job location
  final String location;

  /// Application email
  final String? applicationEmail;

  /// Application URL
  final String? applicationUrl;

  /// Job description (HTML)
  final String description;

  /// Reports to
  final String? reportsTo;

  /// Job type (1: Full-time, etc.)
  final int jobType;

  /// Application deadline
  final String deadline;

  /// Whether cover letter is required (1: yes, 0: no)
  final int coverLetter;

  /// Job slug for URL
  final String slug;

  /// Apply method (email, url, etc.)
  final String applyMethod;

  /// Email subject for applications
  final String? emailSubject;

  /// Company ID
  final int companyId;

  /// Number of posts
  final int numberOfPosts;

  /// View count
  final int countedViews;

  /// Job status (1: active, etc.)
  final int status;

  /// Created at timestamp
  final String createdAt;

  /// Updated at timestamp
  final String updatedAt;

  /// CC email for applications
  final String? applicationEmailCc;

  /// Whether job is remote (1: yes, 0: no)
  final int isRemote;

  /// Minimum salary
  final int? minSalary;

  /// Maximum salary
  final int? maxSalary;

  /// Job keywords
  final String keywords;

  /// Application display columns
  final String? applicationDisplayColumns;

  /// Old ID
  final int? oldId;

  /// Required skills
  final String skills;

  /// Required education
  final String? requiredEducation;

  /// Required education level
  final String? requiredEducationLevel;

  /// Application count
  final int applicationsCount;

  /// View count
  final int viewsCount;

  /// Click count
  final int clicksCount;

  /// Whether user has applied for this job
  final bool applied;

  /// Whether user has saved this job
  final bool isSaved;

  /// Current status text
  final String currentStatus;

  /// Time ago text
  final String timeAgo;

  /// Promotion details
  final PromotionDetails? promotionDetails;

  /// Categorized jobs
  final dynamic categorizedJobs;

  /// Closing time text
  final String closingTime;

  /// Whether job has expired
  final bool expired;

  /// Company information
  final CompanyDetails company;

  /// Job type information
  final JobType type;

  /// Promotion information
  final dynamic promotion;

  /// Screenings information
  final List<dynamic> screenings;

  /// Constructor
  const JobDetails({
    required this.id,
    required this.title,
    required this.location,
    this.applicationEmail,
    this.applicationUrl,
    required this.description,
    this.reportsTo,
    required this.jobType,
    required this.deadline,
    required this.coverLetter,
    required this.slug,
    required this.applyMethod,
    this.emailSubject,
    required this.companyId,
    required this.numberOfPosts,
    required this.countedViews,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.applicationEmailCc,
    required this.isRemote,
    this.minSalary,
    this.maxSalary,
    required this.keywords,
    this.applicationDisplayColumns,
    this.oldId,
    required this.skills,
    required this.requiredEducation,
    required this.requiredEducationLevel,
    required this.applicationsCount,
    required this.viewsCount,
    required this.clicksCount,
    required this.applied,
    this.isSaved = false,
    required this.currentStatus,
    required this.timeAgo,
    this.promotionDetails,
    this.categorizedJobs,
    required this.closingTime,
    required this.expired,
    required this.company,
    required this.type,
    this.promotion,
    required this.screenings,
  });

  /// Create a copy of this JobDetails with the given fields replaced with the new values
  JobDetails copyWith({
    int? id,
    String? title,
    String? location,
    String? applicationEmail,
    String? applicationUrl,
    String? description,
    String? reportsTo,
    int? jobType,
    String? deadline,
    int? coverLetter,
    String? slug,
    String? applyMethod,
    String? emailSubject,
    int? companyId,
    int? numberOfPosts,
    int? countedViews,
    int? status,
    String? createdAt,
    String? updatedAt,
    String? applicationEmailCc,
    int? isRemote,
    int? minSalary,
    int? maxSalary,
    String? keywords,
    String? applicationDisplayColumns,
    int? oldId,
    String? skills,
    String? requiredEducation,
    String? requiredEducationLevel,
    int? applicationsCount,
    int? viewsCount,
    int? clicksCount,
    bool? applied,
    bool? isSaved,
    String? currentStatus,
    String? timeAgo,
    PromotionDetails? promotionDetails,
    dynamic categorizedJobs,
    String? closingTime,
    bool? expired,
    CompanyDetails? company,
    JobType? type,
    dynamic promotion,
    List<dynamic>? screenings,
  }) {
    return JobDetails(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      applicationEmail: applicationEmail ?? this.applicationEmail,
      applicationUrl: applicationUrl ?? this.applicationUrl,
      description: description ?? this.description,
      reportsTo: reportsTo ?? this.reportsTo,
      jobType: jobType ?? this.jobType,
      deadline: deadline ?? this.deadline,
      coverLetter: coverLetter ?? this.coverLetter,
      slug: slug ?? this.slug,
      applyMethod: applyMethod ?? this.applyMethod,
      emailSubject: emailSubject ?? this.emailSubject,
      companyId: companyId ?? this.companyId,
      numberOfPosts: numberOfPosts ?? this.numberOfPosts,
      countedViews: countedViews ?? this.countedViews,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      applicationEmailCc: applicationEmailCc ?? this.applicationEmailCc,
      isRemote: isRemote ?? this.isRemote,
      minSalary: minSalary ?? this.minSalary,
      maxSalary: maxSalary ?? this.maxSalary,
      keywords: keywords ?? this.keywords,
      applicationDisplayColumns: applicationDisplayColumns ?? this.applicationDisplayColumns,
      oldId: oldId ?? this.oldId,
      skills: skills ?? this.skills,
      requiredEducation: requiredEducation ?? this.requiredEducation,
      requiredEducationLevel: requiredEducationLevel ?? this.requiredEducationLevel,
      applicationsCount: applicationsCount ?? this.applicationsCount,
      viewsCount: viewsCount ?? this.viewsCount,
      clicksCount: clicksCount ?? this.clicksCount,
      applied: applied ?? this.applied,
      isSaved: isSaved ?? this.isSaved,
      currentStatus: currentStatus ?? this.currentStatus,
      timeAgo: timeAgo ?? this.timeAgo,
      promotionDetails: promotionDetails ?? this.promotionDetails,
      categorizedJobs: categorizedJobs ?? this.categorizedJobs,
      closingTime: closingTime ?? this.closingTime,
      expired: expired ?? this.expired,
      company: company ?? this.company,
      type: type ?? this.type,
      promotion: promotion ?? this.promotion,
      screenings: screenings ?? this.screenings,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        location,
        applicationEmail,
        applicationUrl,
        description,
        reportsTo,
        jobType,
        deadline,
        coverLetter,
        slug,
        applyMethod,
        emailSubject,
        companyId,
        numberOfPosts,
        countedViews,
        status,
        createdAt,
        updatedAt,
        applicationEmailCc,
        isRemote,
        minSalary,
        maxSalary,
        keywords,
        applicationDisplayColumns,
        oldId,
        skills,
        requiredEducation,
        requiredEducationLevel,
        applicationsCount,
        viewsCount,
        clicksCount,
        applied,
        isSaved,
        currentStatus,
        timeAgo,
        promotionDetails,
        categorizedJobs,
        closingTime,
        expired,
        company,
        type,
        promotion,
        screenings,
      ];
}

/// Company details entity
class CompanyDetails extends Equatable {
  /// Company ID
  final int id;

  /// Company name
  final String name;

  /// Company logo
  final String? logo;

  /// Company slug
  final String slug;

  /// Company website
  final String? website;

  /// Industry ID
  final int? industryId;

  /// Company logo URL
  final String? logoUrl;

  /// Company cover URL
  final String? coverUrl;

  /// Industry information
  final dynamic industry;

  /// Media information
  final List<Media> media;

  /// Constructor
  const CompanyDetails({
    required this.id,
    required this.name,
    this.logo,
    required this.slug,
    this.website,
    this.industryId,
    this.logoUrl,
    this.coverUrl,
    this.industry,
    required this.media,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        logo,
        slug,
        website,
        industryId,
        logoUrl,
        coverUrl,
        industry,
        media,
      ];
}

/// Media entity
class Media extends Equatable {
  /// Media ID
  final int id;

  /// Model type
  final String modelType;

  /// UUID
  final String uuid;

  /// Model ID
  final int modelId;

  /// Collection name
  final String collectionName;

  /// Name
  final String name;

  /// File name
  final String fileName;

  /// MIME type
  final String mimeType;

  /// Disk
  final String disk;

  /// Conversions disk
  final String conversionsDisk;

  /// Size
  final int size;

  /// Manipulations
  final List<dynamic> manipulations;

  /// Custom properties
  final List<dynamic> customProperties;

  /// Generated conversions
  final List<dynamic> generatedConversions;

  /// Responsive images
  final List<dynamic> responsiveImages;

  /// Order column
  final int orderColumn;

  /// Created at timestamp
  final String createdAt;

  /// Updated at timestamp
  final String updatedAt;

  /// Original URL
  final String originalUrl;

  /// Preview URL
  final String previewUrl;

  /// Constructor
  const Media({
    required this.id,
    required this.modelType,
    required this.uuid,
    required this.modelId,
    required this.collectionName,
    required this.name,
    required this.fileName,
    required this.mimeType,
    required this.disk,
    required this.conversionsDisk,
    required this.size,
    required this.manipulations,
    required this.customProperties,
    required this.generatedConversions,
    required this.responsiveImages,
    required this.orderColumn,
    required this.createdAt,
    required this.updatedAt,
    required this.originalUrl,
    required this.previewUrl,
  });

  @override
  List<Object?> get props => [
        id,
        modelType,
        uuid,
        modelId,
        collectionName,
        name,
        fileName,
        mimeType,
        disk,
        conversionsDisk,
        size,
        manipulations,
        customProperties,
        generatedConversions,
        responsiveImages,
        orderColumn,
        createdAt,
        updatedAt,
        originalUrl,
        previewUrl,
      ];
}

/// Job type entity
class JobType extends Equatable {
  /// Job type ID
  final int id;

  /// Job type name
  final String name;

  /// Created at timestamp
  final String createdAt;

  /// Updated at timestamp
  final String updatedAt;

  /// Constructor
  const JobType({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, createdAt, updatedAt];
}

/// Promotion details entity
class PromotionDetails extends Equatable {
  /// Cost per click
  final int costPerClick;

  /// Cost per application
  final int costPerApplication;

  /// Cost per impression
  final int costPerImpression;

  /// Constructor
  const PromotionDetails({
    required this.costPerClick,
    required this.costPerApplication,
    required this.costPerImpression,
  });

  @override
  List<Object?> get props => [
        costPerClick,
        costPerApplication,
        costPerImpression,
      ];
}
