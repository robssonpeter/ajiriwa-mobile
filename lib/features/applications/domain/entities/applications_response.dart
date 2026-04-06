import 'package:equatable/equatable.dart';

import 'application.dart';

/// Applications response entity representing a paginated list of applications
class ApplicationsResponse extends Equatable {
  /// Current page number
  final int currentPage;
  
  /// List of applications
  final List<Application> applications;
  
  /// First page URL
  final String firstPageUrl;
  
  /// Starting index
  final int from;
  
  /// Last page number
  final int lastPage;
  
  /// Last page URL
  final String lastPageUrl;
  
  /// Pagination links
  final List<PaginationLink> links;
  
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
  const ApplicationsResponse({
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

  @override
  List<Object?> get props => [
    currentPage,
    applications,
    firstPageUrl,
    from,
    lastPage,
    lastPageUrl,
    links,
    nextPageUrl,
    path,
    perPage,
    prevPageUrl,
    to,
    total,
  ];
}

/// Pagination link entity
class PaginationLink extends Equatable {
  /// URL for the link
  final String? url;
  
  /// Label for the link
  final String label;
  
  /// Whether the link is active
  final bool active;

  /// Constructor
  const PaginationLink({
    this.url,
    required this.label,
    required this.active,
  });

  @override
  List<Object?> get props => [url, label, active];
}