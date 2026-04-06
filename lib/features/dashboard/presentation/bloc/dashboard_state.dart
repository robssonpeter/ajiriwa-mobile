import 'package:equatable/equatable.dart';

import '../../domain/entities/dashboard.dart';

/// Base class for all dashboard states
abstract class DashboardState extends Equatable {
  /// Constructor
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial dashboard state
class DashboardInitial extends DashboardState {}

/// Loading dashboard state
class DashboardLoading extends DashboardState {}

/// Loaded dashboard state
class DashboardLoaded extends DashboardState {
  /// Dashboard data
  final Dashboard dashboard;

  /// Constructor
  const DashboardLoaded(this.dashboard);

  @override
  List<Object?> get props => [dashboard];
}

/// Dashboard error state
class DashboardError extends DashboardState {
  /// Error message
  final String message;

  /// Constructor
  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}