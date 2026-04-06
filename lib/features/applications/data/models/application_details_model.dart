import '../../domain/entities/application_details.dart';

/// Application details model
class ApplicationDetailsModel extends ApplicationDetails {
  /// Constructor
  const ApplicationDetailsModel({
    required super.id,
    required super.jobId,
    required super.candidateId,
    required super.coverLetter,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    required super.autoApplied,
    required super.appliedOn,
    required super.applicationDate,
    required super.applicationDateTime,
    required super.applicationStatus,
    required super.currentStatus,
    required super.timeAgo,
    required super.attachments,
    required super.job,
    required super.screeningResponses,
    required super.logs,
    super.schedule,
  });

  /// Create a model from JSON
  factory ApplicationDetailsModel.fromJson(Map<String, dynamic> json) {
    return ApplicationDetailsModel(
      id: json['id'],
      jobId: json['job_id'],
      candidateId: json['candidate_id'],
      coverLetter: json['cover_letter'] ?? '',
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      autoApplied: json['auto_applied'],
      appliedOn: json['applied_on'],
      applicationDate: json['application_date'],
      applicationDateTime: json['application_date_time'],
      applicationStatus: json['application_status'],
      currentStatus: json['current_status'],
      timeAgo: json['time_ago'],
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((attachment) => ApplicationAttachmentModel.fromJson(attachment))
          .toList() ?? [],
      job: ApplicationJobModel.fromJson(json['job']),
      screeningResponses: (json['screening_responses'] as List<dynamic>?)
          ?.map((response) => ScreeningResponseModel.fromJson(response))
          .toList() ?? [],
      logs: json['logs'] as List<dynamic>? ?? [],
      schedule: json['schedule'],
    );
  }

  /// Convert model to entity
  ApplicationDetails toEntity() => this;
}

/// Application attachment model
class ApplicationAttachmentModel extends ApplicationAttachment {
  /// Constructor
  const ApplicationAttachmentModel({
    required super.id,
    required super.name,
    required super.institution,
    required super.candidateId,
    required super.category,
    required super.mediaId,
    super.countryId,
    super.validUntil,
    required super.completionDate,
    required super.createdAt,
    required super.updatedAt,
    required super.laravelThroughKey,
    required super.saving,
    required super.mediaUrl,
    required super.media,
  });

  /// Create a model from JSON
  factory ApplicationAttachmentModel.fromJson(Map<String, dynamic> json) {
    return ApplicationAttachmentModel(
      id: json['id'],
      name: json['name'],
      institution: json['institution'],
      candidateId: json['candidate_id'],
      category: json['category'],
      mediaId: json['media_id'],
      countryId: json['country_id'],
      validUntil: json['valid_until'],
      completionDate: json['completion_date'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      laravelThroughKey: json['laravel_through_key'],
      saving: json['saving'] ?? false,
      mediaUrl: json['media_url'],
      media: AttachmentMediaModel.fromJson(json['media']),
    );
  }

  /// Convert model to entity
  ApplicationAttachment toEntity() => this;
}

/// Attachment media model
class AttachmentMediaModel extends AttachmentMedia {
  /// Constructor
  const AttachmentMediaModel({
    required super.id,
    required super.modelType,
    super.uuid,
    required super.modelId,
    required super.collectionName,
    required super.name,
    required super.fileName,
    required super.mimeType,
    required super.disk,
    super.conversionsDisk,
    required super.size,
    required super.manipulations,
    required super.customProperties,
    super.generatedConversions,
    required super.responsiveImages,
    required super.orderColumn,
    required super.createdAt,
    required super.updatedAt,
    required super.originalUrl,
    required super.previewUrl,
  });

  /// Create a model from JSON
  factory AttachmentMediaModel.fromJson(Map<String, dynamic> json) {
    return AttachmentMediaModel(
      id: json['id'],
      modelType: json['model_type'],
      uuid: json['uuid'],
      modelId: json['model_id'],
      collectionName: json['collection_name'],
      name: json['name'],
      fileName: json['file_name'],
      mimeType: json['mime_type'],
      disk: json['disk'],
      conversionsDisk: json['conversions_disk'],
      size: json['size'],
      manipulations: json['manipulations'] as List<dynamic>? ?? [],
      customProperties: json['custom_properties'] as Map<String, dynamic>? ?? {},
      generatedConversions: json['generated_conversions'],
      responsiveImages: json['responsive_images'] as List<dynamic>? ?? [],
      orderColumn: json['order_column'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      originalUrl: json['original_url'],
      previewUrl: json['preview_url'],
    );
  }

  /// Convert model to entity
  AttachmentMedia toEntity() => this;
}

/// Application job model
class ApplicationJobModel extends ApplicationJob {
  /// Constructor
  const ApplicationJobModel({
    required super.id,
    required super.title,
    required super.jobType,
    required super.deadline,
    required super.companyId,
    required super.applied,
    super.currentStatus,
    required super.timeAgo,
    super.promotionDetails,
    super.categorizedJobs,
    required super.closingTime,
    required super.expired,
    required super.company,
    required super.type,
    super.promotion,
  });

  /// Create a model from JSON
  factory ApplicationJobModel.fromJson(Map<String, dynamic> json) {
    return ApplicationJobModel(
      id: json['id'],
      title: json['title'],
      jobType: json['job_type'],
      deadline: json['deadline'],
      companyId: json['company_id'],
      applied: json['applied'] ?? false,
      currentStatus: json['current_status'],
      timeAgo: json['time_ago'],
      promotionDetails: json['promotion_details'] as Map<String, dynamic>?,
      categorizedJobs: json['categorized_jobs'],
      closingTime: json['closing_time'],
      expired: json['expired'] ?? false,
      company: ApplicationCompanyModel.fromJson(json['company']),
      type: ApplicationJobTypeModel.fromJson(json['type']),
      promotion: json['promotion'],
    );
  }

  /// Convert model to entity
  ApplicationJob toEntity() => this;
}

/// Application company model
class ApplicationCompanyModel extends ApplicationCompany {
  /// Constructor
  const ApplicationCompanyModel({
    required super.id,
    required super.name,
    required super.logoUrl,
    required super.coverUrl,
    super.industry,
    required super.media,
  });

  /// Create a model from JSON
  factory ApplicationCompanyModel.fromJson(Map<String, dynamic> json) {
    return ApplicationCompanyModel(
      id: json['id'],
      name: json['name'],
      logoUrl: json['logo_url'],
      coverUrl: json['cover_url'],
      industry: json['industry'],
      media: (json['media'] as List<dynamic>?)
          ?.map((media) => ApplicationMediaModel.fromJson(media))
          .toList() ?? [],
    );
  }

  /// Convert model to entity
  ApplicationCompany toEntity() => this;
}

/// Application media model
class ApplicationMediaModel extends ApplicationMedia {
  /// Constructor
  const ApplicationMediaModel({
    required super.id,
    required super.modelType,
    super.uuid,
    required super.modelId,
    required super.collectionName,
    required super.name,
    required super.fileName,
    required super.mimeType,
    required super.disk,
    super.conversionsDisk,
    required super.size,
    required super.manipulations,
    required super.customProperties,
    super.generatedConversions,
    required super.responsiveImages,
    required super.orderColumn,
    required super.createdAt,
    required super.updatedAt,
    required super.originalUrl,
    required super.previewUrl,
  });

  /// Create a model from JSON
  factory ApplicationMediaModel.fromJson(Map<String, dynamic> json) {
    return ApplicationMediaModel(
      id: json['id'],
      modelType: json['model_type'],
      uuid: json['uuid'],
      modelId: json['model_id'],
      collectionName: json['collection_name'],
      name: json['name'],
      fileName: json['file_name'],
      mimeType: json['mime_type'],
      disk: json['disk'],
      conversionsDisk: json['conversions_disk'],
      size: json['size'],
      manipulations: json['manipulations'] as List<dynamic>? ?? [],
      customProperties: json['custom_properties'],
      generatedConversions: json['generated_conversions'],
      responsiveImages: json['responsive_images'] as List<dynamic>? ?? [],
      orderColumn: json['order_column'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      originalUrl: json['original_url'],
      previewUrl: json['preview_url'],
    );
  }

  /// Convert model to entity
  ApplicationMedia toEntity() => this;
}

/// Application job type model
class ApplicationJobTypeModel extends ApplicationJobType {
  /// Constructor
  const ApplicationJobTypeModel({
    required super.id,
    required super.name,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create a model from JSON
  factory ApplicationJobTypeModel.fromJson(Map<String, dynamic> json) {
    return ApplicationJobTypeModel(
      id: json['id'],
      name: json['name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  /// Convert model to entity
  ApplicationJobType toEntity() => this;
}

/// Screening response model
class ScreeningResponseModel extends ScreeningResponse {
  /// Constructor
  const ScreeningResponseModel({
    required super.id,
    required super.applicationId,
    required super.jobId,
    required super.screeningId,
    required super.type,
    required super.response,
    super.createdAt,
    super.updatedAt,
    required super.question,
  });

  /// Create a model from JSON
  factory ScreeningResponseModel.fromJson(Map<String, dynamic> json) {
    return ScreeningResponseModel(
      id: json['id'],
      applicationId: json['application_id'],
      jobId: json['job_id'],
      screeningId: json['screening_id'],
      type: json['type'],
      response: json['response'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      question: json['question'],
    );
  }

  /// Convert model to entity
  ScreeningResponse toEntity() => this;
}