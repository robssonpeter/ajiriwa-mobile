import 'package:equatable/equatable.dart';

/// Base class for all dashboard events
abstract class DashboardEvent extends Equatable {
  /// Constructor
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Load dashboard data event
class LoadDashboardEvent extends DashboardEvent {}