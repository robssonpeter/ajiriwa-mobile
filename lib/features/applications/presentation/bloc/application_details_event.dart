import 'package:equatable/equatable.dart';

/// Base class for application details events
abstract class ApplicationDetailsEvent extends Equatable {
  /// Constructor
  const ApplicationDetailsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load application details
class LoadApplicationDetailsEvent extends ApplicationDetailsEvent {
  /// Application ID
  final int applicationId;

  /// Constructor
  const LoadApplicationDetailsEvent(this.applicationId);

  @override
  List<Object?> get props => [applicationId];
}

/// Event to withdraw an application
class WithdrawApplicationEvent extends ApplicationDetailsEvent {
  /// Application ID
  final int applicationId;

  /// Constructor
  const WithdrawApplicationEvent(this.applicationId);

  @override
  List<Object?> get props => [applicationId];
}