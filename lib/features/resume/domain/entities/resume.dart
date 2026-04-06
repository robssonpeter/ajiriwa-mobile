import 'package:equatable/equatable.dart';

/// Resume entity
class Resume extends Equatable {
  /// Candidate ID
  final int candidateId;

  /// Profile completion percentage
  final int profileCompletion;

  /// Next section URL
  final String? next;

  /// Previous section URL
  final String? previous;

  /// Constructor
  const Resume({
    required this.candidateId,
    required this.profileCompletion,
    this.next,
    this.previous,
  });

  @override
  List<Object?> get props => [candidateId, profileCompletion, next, previous];
}