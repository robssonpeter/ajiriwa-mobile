import 'package:equatable/equatable.dart';

import '../../domain/entities/job_details.dart';

/// Job details model
class JobDetailsModel extends Equatable {
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

  /// Current status text
  final String currentStatus;

  /// Time ago text
  final String timeAgo;

  /// Promotion details
  final PromotionDetailsModel? promotionDetails;

  /// Categorized jobs
  final dynamic categorizedJobs;

  /// Closing time text
  final String closingTime;

  /// Whether job has expired
  final bool expired;

  /// Company information
  final CompanyDetailsModel company;

  /// Job type information
  final JobTypeModel type;

  /// Promotion information
  final dynamic promotion;

  /// Screenings information
  final List<dynamic> screenings;

  /// Constructor
  const JobDetailsModel({
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

  /// Create a job details model from JSON
  factory JobDetailsModel.fromJson(Map<String, dynamic> json) {
    return JobDetailsModel(
      id: json['id'] != null ? json['id'] as int : 0,
      title: json['title'] != null ? json['title'] as String : "",
      location: json['location'] != null ? json['location'] as String : "",
      applicationEmail: json['application_email'] as String?,
      applicationUrl: json['application_url'] as String?,
      description: json['description'] != null ? json['description'] as String : "",
      reportsTo: json['reports_to'] as String?,
      jobType: json['job_type'] != null ? json['job_type'] as int : 0,
      deadline: json['deadline'] != null ? json['deadline'] as String : "",
      coverLetter: json['cover_letter'] != null ? json['cover_letter'] as int : 0,
      slug: json['slug'] != null ? json['slug'] as String : "",
      applyMethod: json['apply_method'] != null ? json['apply_method'] as String : "",
      emailSubject: json['email_subject'] as String?,
      companyId: json['company_id'] != null ? json['company_id'] as int : 0,
      numberOfPosts: json['number_of_posts'] != null ? json['number_of_posts'] as int : 0,
      countedViews: json['counted_views'] != null ? json['counted_views'] as int : 0,
      status: json['status'] != null ? json['status'] as int : 0,
      createdAt: json['created_at'] != null ? json['created_at'] as String : "",
      updatedAt: json['updated_at'] != null ? json['updated_at'] as String : "",
      applicationEmailCc: json['application_email_cc'] as String?,
      isRemote: json['is_remote'] != null ? json['is_remote'] as int : 0,
      minSalary: json['min_salary'] as int?,
      maxSalary: json['max_salary'] as int?,
      keywords: json['keywords'] != null ? json['keywords'] as String : "",
      applicationDisplayColumns: json['application_display_columns'] as String?,
      oldId: json['old_id'] as int?,
      skills: json['skills'] != null ? json['skills'] as String : "",
      requiredEducation: json['required_education'] as String?,
      requiredEducationLevel: json['required_education_level'] as String?,
      applicationsCount: json['applications_count'] != null ? json['applications_count'] as int : 0,
      viewsCount: json['views_count'] != null ? json['views_count'] as int : 0,
      clicksCount: json['clicks_count'] != null ? json['clicks_count'] as int : 0,
      applied: json['applied'] != null ? json['applied'] as bool : false,
      currentStatus: json['current_status'] != null ? json['current_status'] as String : "",
      timeAgo: json['time_ago'] != null ? json['time_ago'] as String : "",
      promotionDetails: json['promotion_details'] != null
          ? PromotionDetailsModel.fromJson(
              json['promotion_details'] as Map<String, dynamic>)
          : null,
      categorizedJobs: json['categorized_jobs'],
      closingTime: json['closing_time'] != null ? json['closing_time'] as String : "",
      expired: json['expired'] != null ? json['expired'] as bool : false,
      company: CompanyDetailsModel.fromJson(
          json['company'] as Map<String, dynamic>),
      type: json['type'] != null 
          ? JobTypeModel.fromJson(json['type'] as Map<String, dynamic>)
          : const JobTypeModel(id: 0, name: "", createdAt: "", updatedAt: ""),
      promotion: json['promotion'],
      screenings: json['screenings'] != null ? json['screenings'] as List<dynamic> : [],
    );
  }

  /// Convert model to entity
  JobDetails toEntity() {
    return JobDetails(
      id: id,
      title: title,
      location: location,
      applicationEmail: applicationEmail,
      applicationUrl: applicationUrl,
      description: description,
      reportsTo: reportsTo,
      jobType: jobType,
      deadline: deadline,
      coverLetter: coverLetter,
      slug: slug,
      applyMethod: applyMethod,
      emailSubject: emailSubject,
      companyId: companyId,
      numberOfPosts: numberOfPosts,
      countedViews: countedViews,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      applicationEmailCc: applicationEmailCc,
      isRemote: isRemote,
      minSalary: minSalary,
      maxSalary: maxSalary,
      keywords: keywords,
      applicationDisplayColumns: applicationDisplayColumns,
      oldId: oldId,
      skills: skills,
      requiredEducation: requiredEducation,
      requiredEducationLevel: requiredEducationLevel,
      applicationsCount: applicationsCount,
      viewsCount: viewsCount,
      clicksCount: clicksCount,
      applied: applied,
      currentStatus: currentStatus,
      timeAgo: timeAgo,
      promotionDetails: promotionDetails?.toEntity(),
      categorizedJobs: categorizedJobs,
      closingTime: closingTime,
      expired: expired,
      company: company.toEntity(),
      type: type.toEntity(),
      promotion: promotion,
      screenings: screenings,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      if (applicationEmail != null) 'application_email': applicationEmail,
      if (applicationUrl != null) 'application_url': applicationUrl,
      'description': description,
      if (reportsTo != null) 'reports_to': reportsTo,
      'job_type': jobType,
      'deadline': deadline,
      'cover_letter': coverLetter,
      'slug': slug,
      'apply_method': applyMethod,
      if (emailSubject != null) 'email_subject': emailSubject,
      'company_id': companyId,
      'number_of_posts': numberOfPosts,
      'counted_views': countedViews,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      if (applicationEmailCc != null) 'application_email_cc': applicationEmailCc,
      'is_remote': isRemote,
      if (minSalary != null) 'min_salary': minSalary,
      if (maxSalary != null) 'max_salary': maxSalary,
      'keywords': keywords,
      if (applicationDisplayColumns != null) 'application_display_columns': applicationDisplayColumns,
      if (oldId != null) 'old_id': oldId,
      'skills': skills,
      if (requiredEducation != null) 'required_education': requiredEducation,
      if (requiredEducationLevel != null) 'required_education_level': requiredEducationLevel,
      'applications_count': applicationsCount,
      'views_count': viewsCount,
      'clicks_count': clicksCount,
      'applied': applied,
      'current_status': currentStatus,
      'time_ago': timeAgo,
      if (promotionDetails != null) 'promotion_details': promotionDetails!.toJson(),
      if (categorizedJobs != null) 'categorized_jobs': categorizedJobs,
      'closing_time': closingTime,
      'expired': expired,
      'company': company.toJson(),
      'type': type.toJson(),
      if (promotion != null) 'promotion': promotion,
      'screenings': screenings,
    };
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

/// Company details model
class CompanyDetailsModel extends Equatable {
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
  final List<MediaModel> media;

  /// Constructor
  const CompanyDetailsModel({
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

  /// Create a company details model from JSON
  factory CompanyDetailsModel.fromJson(Map<String, dynamic> json) {
    return CompanyDetailsModel(
      id: json['id'] as int,
      name: json['name'] as String,
      logo: json['logo'] as String?,
      slug: json['slug'] != null ? json['slug'] as String : "",
      website: json['website'] as String?,
      industryId: json['industry_id'] as int?,
      logoUrl: json['logo_url'] as String?,
      coverUrl: json['cover_url'] as String?,
      industry: json['industry'],
      media: (json['media'] as List<dynamic>?)
          ?.map((item) => MediaModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  /// Convert model to entity
  CompanyDetails toEntity() {
    return CompanyDetails(
      id: id,
      name: name,
      logo: logo,
      slug: slug,
      website: website,
      industryId: industryId,
      logoUrl: logoUrl,
      coverUrl: coverUrl,
      industry: industry,
      media: media.map((item) => item.toEntity()).toList(),
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (logo != null) 'logo': logo,
      'slug': slug,
      if (website != null) 'website': website,
      if (industryId != null) 'industry_id': industryId,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (industry != null) 'industry': industry,
      'media': media.map((item) => item.toJson()).toList(),
    };
  }

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

/// Media model
class MediaModel extends Equatable {
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
  const MediaModel({
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

  /// Create a media model from JSON
  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'] as int,
      modelType: json['model_type'] != null ? json['model_type'] as String : "",
      uuid: "",//(json['uuid'] as String) ?? json['id'].toString(),
      modelId: json['model_id'] != null ? json['model_id'] as int : 0,
      collectionName: json['collection_name'] != null ? json['collection_name'] as String : "",
      name: json['name'] != null ? json['name'] as String : "",
      fileName: json['file_name'] != null ? json['file_name'] as String : "",
      mimeType: json['mime_type'] != null ? json['mime_type'] as String : "",
      disk: json['disk'] != null ? json['disk'] as String : "",
      conversionsDisk: "",//(json['conversions_disk'] as String) ?? "",
      size: json['size'] != null ? json['size'] as int : 0,
      manipulations: (json['manipulations'] as List<dynamic>) ?? [],
      customProperties: (json['custom_properties'] as List<dynamic>) ?? [],
      generatedConversions: json['generated_conversions'] != null ? json['generated_conversions'] as List<dynamic>: [], //(json['generated_conversions'] as List<dynamic>) ?? [],
      responsiveImages: (json['responsive_images'] as List<dynamic>) ?? [],
      orderColumn: json['order_column'] != null ? json['order_column'] as int : 0,
      createdAt: json['created_at'] != null ? json['created_at'] as String : "",
      updatedAt: json['updated_at'] != null ? json['updated_at'] as String : "",
      originalUrl: json['original_url'] != null ? json['original_url'] as String : "",
      previewUrl: json['preview_url'] != null ? json['preview_url'] as String : "",
    );
  }

  /// Convert model to entity
  Media toEntity() {
    return Media(
      id: id,
      modelType: modelType,
      uuid: uuid,
      modelId: modelId,
      collectionName: collectionName,
      name: name,
      fileName: fileName,
      mimeType: mimeType,
      disk: disk,
      conversionsDisk: conversionsDisk,
      size: size,
      manipulations: manipulations,
      customProperties: customProperties,
      generatedConversions: generatedConversions,
      responsiveImages: responsiveImages,
      orderColumn: orderColumn,
      createdAt: createdAt,
      updatedAt: updatedAt,
      originalUrl: originalUrl,
      previewUrl: previewUrl,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'model_type': modelType,
      'uuid': uuid,
      'model_id': modelId,
      'collection_name': collectionName,
      'name': name,
      'file_name': fileName,
      'mime_type': mimeType,
      'disk': disk,
      'conversions_disk': conversionsDisk,
      'size': size,
      'manipulations': manipulations,
      'custom_properties': customProperties,
      'generated_conversions': generatedConversions,
      'responsive_images': responsiveImages,
      'order_column': orderColumn,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'original_url': originalUrl,
      'preview_url': previewUrl,
    };
  }

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

/// Job type model
class JobTypeModel extends Equatable {
  /// Job type ID
  final int id;

  /// Job type name
  final String name;

  /// Created at timestamp
  final String createdAt;

  /// Updated at timestamp
  final String updatedAt;

  /// Constructor
  const JobTypeModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a job type model from JSON
  factory JobTypeModel.fromJson(Map<String, dynamic> json) {
    return JobTypeModel(
      id: json['id'] != null ? json['id'] as int : 0,
      name: json['name'] != null ? json['name'] as String : "",
      createdAt: json['created_at'] != null ? json['created_at'] as String : "",
      updatedAt: json['updated_at'] != null ? json['updated_at'] as String : "",
    );
  }

  /// Convert model to entity
  JobType toEntity() {
    return JobType(
      id: id,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [id, name, createdAt, updatedAt];
}

/// Promotion details model
class PromotionDetailsModel extends Equatable {
  /// Cost per click
  final int costPerClick;

  /// Cost per application
  final int costPerApplication;

  /// Cost per impression
  final int costPerImpression;

  /// Constructor
  const PromotionDetailsModel({
    required this.costPerClick,
    required this.costPerApplication,
    required this.costPerImpression,
  });

  /// Create a promotion details model from JSON
  factory PromotionDetailsModel.fromJson(Map<String, dynamic> json) {
    return PromotionDetailsModel(
      costPerClick: json['cost_per_click'] != null ? json['cost_per_click'] as int : 0,
      costPerApplication: json['cost_per_application'] != null ? json['cost_per_application'] as int : 0,
      costPerImpression: json['cost_per_impression'] != null ? json['cost_per_impression'] as int : 0,
    );
  }

  /// Convert model to entity
  PromotionDetails toEntity() {
    return PromotionDetails(
      costPerClick: costPerClick,
      costPerApplication: costPerApplication,
      costPerImpression: costPerImpression,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'cost_per_click': costPerClick,
      'cost_per_application': costPerApplication,
      'cost_per_impression': costPerImpression,
    };
  }

  @override
  List<Object?> get props => [
        costPerClick,
        costPerApplication,
        costPerImpression,
      ];
}
