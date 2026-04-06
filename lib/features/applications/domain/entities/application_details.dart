import 'package:equatable/equatable.dart';

/// Application details entity
class ApplicationDetails extends Equatable {
  /// Application ID
  final int id;
  
  /// Job ID
  final int jobId;
  
  /// Candidate ID
  final int candidateId;
  
  /// Cover letter
  final String coverLetter;
  
  /// Status code
  final int status;
  
  /// Created at timestamp
  final String createdAt;
  
  /// Updated at timestamp
  final String updatedAt;
  
  /// Whether the application was auto-applied
  final int autoApplied;
  
  /// Applied on date
  final String appliedOn;
  
  /// Application date
  final String applicationDate;
  
  /// Application date and time
  final String applicationDateTime;
  
  /// Application status text
  final String applicationStatus;
  
  /// Current status text
  final String currentStatus;
  
  /// Time ago text
  final String timeAgo;
  
  /// Attachments
  final List<ApplicationAttachment> attachments;
  
  /// Job details
  final ApplicationJob job;
  
  /// Screening responses
  final List<ScreeningResponse> screeningResponses;
  
  /// Application logs
  final List<dynamic> logs;
  
  /// Schedule information
  final dynamic schedule;

  /// Constructor
  const ApplicationDetails({
    required this.id,
    required this.jobId,
    required this.candidateId,
    required this.coverLetter,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.autoApplied,
    required this.appliedOn,
    required this.applicationDate,
    required this.applicationDateTime,
    required this.applicationStatus,
    required this.currentStatus,
    required this.timeAgo,
    required this.attachments,
    required this.job,
    required this.screeningResponses,
    required this.logs,
    this.schedule,
  });

  @override
  List<Object?> get props => [
    id,
    jobId,
    candidateId,
    coverLetter,
    status,
    createdAt,
    updatedAt,
    autoApplied,
    appliedOn,
    applicationDate,
    applicationDateTime,
    applicationStatus,
    currentStatus,
    timeAgo,
    attachments,
    job,
    screeningResponses,
    logs,
    schedule,
  ];
}

/// Application attachment entity
class ApplicationAttachment extends Equatable {
  /// Attachment ID
  final int id;
  
  /// Attachment name
  final String name;
  
  /// Institution
  final String institution;
  
  /// Candidate ID
  final int candidateId;
  
  /// Category
  final int category;
  
  /// Media ID
  final int mediaId;
  
  /// Country ID
  final int? countryId;
  
  /// Valid until date
  final String? validUntil;
  
  /// Completion date
  final String completionDate;
  
  /// Created at timestamp
  final String createdAt;
  
  /// Updated at timestamp
  final String updatedAt;
  
  /// Laravel through key
  final int laravelThroughKey;
  
  /// Whether the attachment is being saved
  final bool saving;
  
  /// Media URL
  final String mediaUrl;
  
  /// Media information
  final AttachmentMedia media;

  /// Constructor
  const ApplicationAttachment({
    required this.id,
    required this.name,
    required this.institution,
    required this.candidateId,
    required this.category,
    required this.mediaId,
    this.countryId,
    this.validUntil,
    required this.completionDate,
    required this.createdAt,
    required this.updatedAt,
    required this.laravelThroughKey,
    required this.saving,
    required this.mediaUrl,
    required this.media,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    institution,
    candidateId,
    category,
    mediaId,
    countryId,
    validUntil,
    completionDate,
    createdAt,
    updatedAt,
    laravelThroughKey,
    saving,
    mediaUrl,
    media,
  ];
}

/// Attachment media entity
class AttachmentMedia extends Equatable {
  /// Media ID
  final int id;
  
  /// Model type
  final String modelType;
  
  /// UUID
  final String? uuid;
  
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
  final String? conversionsDisk;
  
  /// Size
  final int size;
  
  /// Manipulations
  final List<dynamic> manipulations;
  
  /// Custom properties
  final Map<String, dynamic> customProperties;
  
  /// Generated conversions
  final dynamic generatedConversions;
  
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
  const AttachmentMedia({
    required this.id,
    required this.modelType,
    this.uuid,
    required this.modelId,
    required this.collectionName,
    required this.name,
    required this.fileName,
    required this.mimeType,
    required this.disk,
    this.conversionsDisk,
    required this.size,
    required this.manipulations,
    required this.customProperties,
    this.generatedConversions,
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

/// Application job entity
class ApplicationJob extends Equatable {
  /// Job ID
  final int id;
  
  /// Job title
  final String title;
  
  /// Job type
  final int jobType;
  
  /// Deadline
  final String deadline;
  
  /// Company ID
  final int companyId;
  
  /// Whether the user has applied for this job
  final bool applied;
  
  /// Current status
  final String? currentStatus;
  
  /// Time ago text
  final String timeAgo;
  
  /// Promotion details
  final Map<String, dynamic>? promotionDetails;
  
  /// Categorized jobs
  final dynamic categorizedJobs;
  
  /// Closing time text
  final String closingTime;
  
  /// Whether the job has expired
  final bool expired;
  
  /// Company information
  final ApplicationCompany company;
  
  /// Job type information
  final ApplicationJobType type;
  
  /// Promotion information
  final dynamic promotion;

  /// Constructor
  const ApplicationJob({
    required this.id,
    required this.title,
    required this.jobType,
    required this.deadline,
    required this.companyId,
    required this.applied,
    this.currentStatus,
    required this.timeAgo,
    this.promotionDetails,
    this.categorizedJobs,
    required this.closingTime,
    required this.expired,
    required this.company,
    required this.type,
    this.promotion,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    jobType,
    deadline,
    companyId,
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
  ];
}

/// Application company entity
class ApplicationCompany extends Equatable {
  /// Company ID
  final int id;
  
  /// Company name
  final String name;
  
  /// Logo URL
  final String logoUrl;
  
  /// Cover URL
  final String coverUrl;
  
  /// Industry
  final dynamic industry;
  
  /// Media
  final List<ApplicationMedia> media;

  /// Constructor
  const ApplicationCompany({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.coverUrl,
    this.industry,
    required this.media,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    logoUrl,
    coverUrl,
    industry,
    media,
  ];
}

/// Application media entity
class ApplicationMedia extends Equatable {
  /// Media ID
  final int id;
  
  /// Model type
  final String modelType;
  
  /// UUID
  final String? uuid;
  
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
  final String? conversionsDisk;
  
  /// Size
  final int size;
  
  /// Manipulations
  final List<dynamic> manipulations;
  
  /// Custom properties
  final dynamic customProperties;
  
  /// Generated conversions
  final dynamic generatedConversions;
  
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
  const ApplicationMedia({
    required this.id,
    required this.modelType,
    this.uuid,
    required this.modelId,
    required this.collectionName,
    required this.name,
    required this.fileName,
    required this.mimeType,
    required this.disk,
    this.conversionsDisk,
    required this.size,
    required this.manipulations,
    required this.customProperties,
    this.generatedConversions,
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

/// Application job type entity
class ApplicationJobType extends Equatable {
  /// Job type ID
  final int id;
  
  /// Job type name
  final String name;
  
  /// Created at timestamp
  final String createdAt;
  
  /// Updated at timestamp
  final String updatedAt;

  /// Constructor
  const ApplicationJobType({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    createdAt,
    updatedAt,
  ];
}

/// Screening response entity
class ScreeningResponse extends Equatable {
  /// Response ID
  final int id;
  
  /// Application ID
  final int applicationId;
  
  /// Job ID
  final int jobId;
  
  /// Screening ID
  final int screeningId;
  
  /// Response type
  final String type;
  
  /// Response value
  final String response;
  
  /// Created at timestamp
  final String? createdAt;
  
  /// Updated at timestamp
  final String? updatedAt;
  
  /// Question text
  final String question;

  /// Constructor
  const ScreeningResponse({
    required this.id,
    required this.applicationId,
    required this.jobId,
    required this.screeningId,
    required this.type,
    required this.response,
    this.createdAt,
    this.updatedAt,
    required this.question,
  });

  @override
  List<Object?> get props => [
    id,
    applicationId,
    jobId,
    screeningId,
    type,
    response,
    createdAt,
    updatedAt,
    question,
  ];
}