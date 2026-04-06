import 'package:equatable/equatable.dart';

/// Base class for all saved jobs events
abstract class SavedJobsEvent extends Equatable {
  /// Constructor
  const SavedJobsEvent();

  @override
  List<Object?> get props => [];
}

/// Load saved jobs event
class LoadSavedJobsEvent extends SavedJobsEvent {}

/// Remove job from saved jobs event
class RemoveFromSavedJobsEvent extends SavedJobsEvent {
  /// Job ID
  final int jobId;

  /// Constructor
  const RemoveFromSavedJobsEvent({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}