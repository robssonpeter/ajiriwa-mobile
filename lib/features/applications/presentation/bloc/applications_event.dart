import 'package:equatable/equatable.dart';

/// Base class for all applications events
abstract class ApplicationsEvent extends Equatable {
  /// Constructor
  const ApplicationsEvent();

  @override
  List<Object?> get props => [];
}

/// Load applications event
class LoadApplicationsEvent extends ApplicationsEvent {
  /// Page number
  final int? page;
  
  /// Items per page
  final int? perPage;

  /// Constructor
  const LoadApplicationsEvent({
    this.page,
    this.perPage,
  });

  @override
  List<Object?> get props => [page, perPage];
}

/// Load more applications event (pagination)
class LoadMoreApplicationsEvent extends ApplicationsEvent {}