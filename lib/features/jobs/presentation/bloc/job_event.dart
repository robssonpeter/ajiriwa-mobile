import 'package:equatable/equatable.dart';

/// Base class for all job events
abstract class JobEvent extends Equatable {
  /// Constructor
  const JobEvent();

  @override
  List<Object?> get props => [];
}

/// Load job details event
class LoadJobDetailsEvent extends JobEvent {
  /// Job slug
  final String slug;

  /// Constructor
  const LoadJobDetailsEvent(this.slug);

  @override
  List<Object?> get props => [slug];
}

/// Toggle job saved status event
class ToggleJobSavedEvent extends JobEvent {
  /// Job ID
  final int jobId;

  /// Current saved status
  final bool isSaved;

  /// Constructor
  const ToggleJobSavedEvent({
    required this.jobId,
    required this.isSaved,
  });

  @override
  List<Object?> get props => [jobId, isSaved];
}
