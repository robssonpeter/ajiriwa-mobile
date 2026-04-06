import 'package:equatable/equatable.dart';

import '../../domain/entities/application.dart';
import '../../domain/entities/applications_response.dart';

/// Base class for all applications states
abstract class ApplicationsState extends Equatable {
  /// Constructor
  const ApplicationsState();

  /// Whether there are more applications to load
  /// Default is false for states that don't have this property
  bool get hasMore => false;

  @override
  List<Object?> get props => [];
}

/// Initial applications state
class ApplicationsInitial extends ApplicationsState {}

/// Loading applications state
class ApplicationsLoading extends ApplicationsState {
  /// Whether this is the initial load or a pagination load
  final bool isInitialLoad;

  /// Constructor
  const ApplicationsLoading({this.isInitialLoad = true});

  @override
  List<Object?> get props => [isInitialLoad];
}

/// Loaded applications state
class ApplicationsLoaded extends ApplicationsState {
  /// List of applications
  final List<Application> applications;

  /// Current page
  final int currentPage;

  /// Number of applications per page
  final int perPage;

  /// Total number of applications
  final int total;

  /// Whether there are more applications to load
  final bool hasMore;

  /// Pagination links
  final List<PaginationLink> links;

  /// Constructor
  const ApplicationsLoaded({
    required this.applications,
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.hasMore,
    required this.links,
  });

  /// Create a copy of this ApplicationsLoaded state with the given fields replaced with the new values
  ApplicationsLoaded copyWith({
    List<Application>? applications,
    int? currentPage,
    int? perPage,
    int? total,
    bool? hasMore,
    List<PaginationLink>? links,
  }) {
    return ApplicationsLoaded(
      applications: applications ?? this.applications,
      currentPage: currentPage ?? this.currentPage,
      perPage: perPage ?? this.perPage,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      links: links ?? this.links,
    );
  }

  /// Create an ApplicationsLoaded state from an ApplicationsResponse entity
  factory ApplicationsLoaded.fromApplicationsResponse(
    ApplicationsResponse response,
  ) {
    return ApplicationsLoaded(
      applications: response.applications,
      currentPage: response.currentPage,
      perPage: response.perPage,
      total: response.total,
      hasMore: response.nextPageUrl != null,
      links: response.links,
    );
  }

  @override
  List<Object?> get props => [
        applications,
        currentPage,
        perPage,
        total,
        hasMore,
        links,
      ];
}

/// Loading more applications state (extends ApplicationsLoaded to preserve the current applications list)
class ApplicationsLoadingMore extends ApplicationsLoaded {
  /// Constructor
  const ApplicationsLoadingMore({
    required super.applications,
    required super.currentPage,
    required super.perPage,
    required super.total,
    required super.hasMore,
    required super.links,
  });

  @override
  List<Object?> get props => [
        applications,
        currentPage,
        perPage,
        total,
        hasMore,
        links,
        'loading_more', // Add this to distinguish from ApplicationsLoaded
      ];
}

/// Applications error state
class ApplicationsError extends ApplicationsState {
  /// Error message
  final String message;

  /// Constructor
  const ApplicationsError(this.message);

  @override
  List<Object?> get props => [message];
}
