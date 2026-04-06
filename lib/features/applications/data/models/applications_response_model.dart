import '../../domain/entities/applications_response.dart';
import 'application_model.dart';

/// Model class for ApplicationsResponse
class ApplicationsResponseModel {
  /// Current page number
  final int currentPage;
  
  /// List of applications
  final List<ApplicationModel> applications;
  
  /// First page URL
  final String firstPageUrl;
  
  /// Starting index
  final int from;
  
  /// Last page number
  final int lastPage;
  
  /// Last page URL
  final String lastPageUrl;
  
  /// Pagination links
  final List<PaginationLinkModel> links;
  
  /// Next page URL
  final String? nextPageUrl;
  
  /// API path
  final String path;
  
  /// Items per page
  final int perPage;
  
  /// Previous page URL
  final String? prevPageUrl;
  
  /// Ending index
  final int to;
  
  /// Total number of items
  final int total;

  /// Constructor
  const ApplicationsResponseModel({
    required this.currentPage,
    required this.applications,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  /// Create an ApplicationsResponseModel from JSON
  factory ApplicationsResponseModel.fromJson(Map<String, dynamic> json) {
    return ApplicationsResponseModel(
      currentPage: json['current_page'] as int,
      applications: (json['data'] as List)
          .map((app) => ApplicationModel.fromJson(app as Map<String, dynamic>))
          .toList(),
      firstPageUrl: json['first_page_url'] as String,
      from: json['from'] as int,
      lastPage: json['last_page'] as int,
      lastPageUrl: json['last_page_url'] as String,
      links: (json['links'] as List)
          .map((link) => PaginationLinkModel.fromJson(link as Map<String, dynamic>))
          .toList(),
      nextPageUrl: json['next_page_url'] as String?,
      path: json['path'] as String,
      perPage: json['per_page'] as int,
      prevPageUrl: json['prev_page_url'] as String?,
      to: json['to'] as int,
      total: json['total'] as int,
    );
  }

  /// Convert model to entity
  ApplicationsResponse toEntity() {
    return ApplicationsResponse(
      currentPage: currentPage,
      applications: applications.map((app) => app.toEntity()).toList(),
      firstPageUrl: firstPageUrl,
      from: from,
      lastPage: lastPage,
      lastPageUrl: lastPageUrl,
      links: links.map((link) => link.toEntity()).toList(),
      nextPageUrl: nextPageUrl,
      path: path,
      perPage: perPage,
      prevPageUrl: prevPageUrl,
      to: to,
      total: total,
    );
  }
}

/// Model class for PaginationLink
class PaginationLinkModel {
  /// URL for the link
  final String? url;
  
  /// Label for the link
  final String label;
  
  /// Whether the link is active
  final bool active;

  /// Constructor
  const PaginationLinkModel({
    this.url,
    required this.label,
    required this.active,
  });

  /// Create a PaginationLinkModel from JSON
  factory PaginationLinkModel.fromJson(Map<String, dynamic> json) {
    return PaginationLinkModel(
      url: json['url'] as String?,
      label: json['label'] as String,
      active: json['active'] as bool,
    );
  }

  /// Convert model to entity
  PaginationLink toEntity() {
    return PaginationLink(
      url: url,
      label: label,
      active: active,
    );
  }
}