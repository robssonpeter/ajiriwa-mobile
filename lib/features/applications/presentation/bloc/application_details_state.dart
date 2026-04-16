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

/// Interview prep is being generated
class InterviewPrepLoading extends ApplicationDetailsState {
  final ApplicationDetails applicationDetails;
  const InterviewPrepLoading(this.applicationDetails);
  @override
  List<Object?> get props => [applicationDetails];
}

/// Interview prep loaded successfully
class InterviewPrepLoaded extends ApplicationDetailsState {
  final ApplicationDetails applicationDetails;
  final Map<String, dynamic> prepData;
  const InterviewPrepLoaded({required this.applicationDetails, required this.prepData});
  @override
  List<Object?> get props => [applicationDetails, prepData];
}

/// Interview prep error
class InterviewPrepError extends ApplicationDetailsState {
  final ApplicationDetails applicationDetails;
  final String message;
  const InterviewPrepError({required this.applicationDetails, required this.message});
  @override
  List<Object?> get props => [applicationDetails, message];
}