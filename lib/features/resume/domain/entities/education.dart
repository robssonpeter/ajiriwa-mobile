import 'package:equatable/equatable.dart';

/// Education entity for resume
class Education extends Equatable {
  /// Education ID
  final int? id;

  /// Institution name
  final String institution;

  /// Degree
  final String degree;

  /// Field of study
  final String? fieldOfStudy;

  /// Start date
  final int startDate;

  /// End date (null if current education)
  final String? endDate;

  /// Achievements
  final String? achievements;

  /// Is current education
  final bool isCurrent;

  /// Description
  final String? description;

  /// Education level ID
  final int? educationLevelId;

  /// Education level name
  final String? educationLevel;

  /// Country ID
  final String? countryId;

  /// Constructor
  const Education({
    this.id,
    required this.institution,
    required this.degree,
    this.fieldOfStudy,
    required this.startDate,
    this.endDate,
    this.achievements,
    required this.isCurrent,
    this.description,
    this.educationLevelId,
    this.educationLevel,
    this.countryId,
  });

  @override
  List<Object?> get props => [
        id,
        institution,
        degree,
        fieldOfStudy,
        startDate,
        endDate,
        achievements,
        isCurrent,
        description,
        educationLevelId,
        educationLevel,
        countryId,
      ];
}
