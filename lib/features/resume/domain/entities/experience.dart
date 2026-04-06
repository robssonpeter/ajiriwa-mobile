import 'package:equatable/equatable.dart';

/// Work experience entity for resume
class Experience extends Equatable {
  /// Experience ID
  final int? id;

  /// Job title
  final String jobTitle;

  /// Company name
  final String company;

  /// Start date
  final String startDate;

  /// End date (null if current job)
  final String? endDate;

  /// Is current job
  final bool isCurrent;

  /// Description
  final String? description;

  /// Location
  final String? location;

  /// Constructor
  const Experience({
    this.id,
    required this.jobTitle,
    required this.company,
    required this.startDate,
    this.endDate,
    required this.isCurrent,
    this.description,
    this.location,
  });

  @override
  List<Object?> get props => [
        id,
        jobTitle,
        company,
        startDate,
        endDate,
        isCurrent,
        description,
        location,
      ];
}