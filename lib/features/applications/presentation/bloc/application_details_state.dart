import 'package:equatable/equatable.dart';

import '../../domain/entities/application_details.dart';

/// Base class for application details states
abstract class ApplicationDetailsState extends Equatable {
  /// Constructor
  const ApplicationDetailsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ApplicationDetailsInitial extends ApplicationDetailsState {}

/// Loading state
class ApplicationDetailsLoading extends ApplicationDetailsState {}

/// Loaded state
class ApplicationDetailsLoaded extends ApplicationDetailsState {
  /// Application details
  final ApplicationDetails applicationDetails;

  /// Constructor
  const ApplicationDetailsLoaded(this.applicationDetails);

  @override
  List<Object?> get props => [applicationDetails];
}

/// Error state
class ApplicationDetailsError extends ApplicationDetailsState {
  /// Error message
  final String message;

  /// Constructor
  const ApplicationDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Withdrawal in progress state
class ApplicationWithdrawing extends ApplicationDetailsState {
  const ApplicationWithdrawing();
}

/// Application withdrawn successfully
class ApplicationWithdrawn extends ApplicationDetailsState {
  const ApplicationWithdrawn();
}