import '../../domain/entities/education.dart';

/// Education model for resume
class EducationModel extends Education {
  /// Constructor
  const EducationModel({
    int? id,
    required String institution,
    required String degree,
    String? fieldOfStudy,
    required int startDate,
    String? endDate,
    String? achievements,
    required bool isCurrent,
    String? description,
    int? educationLevelId,
    String? educationLevel,
    String? countryId,
  }) : super(
          id: id,
          institution: institution,
          degree: degree,
          fieldOfStudy: fieldOfStudy,
          startDate: startDate,
          endDate: endDate,
          achievements: achievements,
          isCurrent: isCurrent,
          description: description,
          educationLevelId: educationLevelId,
          educationLevel: educationLevel,
          countryId: countryId,
        );

  /// Create a model from JSON
  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      id: json['id'] as int?,
      institution: json['institution'] as String? ?? '',
      degree: json['degree'] as String? ?? '',
      fieldOfStudy: json['field_of_study'] as String? ?? json['fieldOfStudy'] as String?,
      startDate: () {
        final startDateValue = json['start_date'] ?? json['startDate'];
        if (startDateValue is int) {
          return startDateValue;
        } else if (startDateValue is String) {
          return int.tryParse(startDateValue) ?? 0;
        }
        return 0;
      }(),
      endDate: json['end_date'] as String? ?? json['endDate'] as String?,
      achievements: json['achievements'] as String?,
      isCurrent: json['is_current'] as bool? ?? json['isCurrent'] as bool? ?? false,
      description: json['description'] as String?,
      educationLevelId: json['education_level_id'] as int? ?? json['educationLevelId'] as int?,
      educationLevel: json['education_level'] as String? ?? json['educationLevel'] as String?,
      countryId: json['country_id'] as String? ?? json['countryId'] as String?,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'institute': institution,
      'degree_title': degree,
      'field_of_study': fieldOfStudy,
      'year': endDate,
      'start_year': startDate,
      'end_date': endDate,
      'achievements': achievements,
      'currently_studying': isCurrent,
      'description': description,
      'country_id':  countryId?.isNotEmpty == true ? countryId?.toUpperCase() : countryId,
      'degree_level_id': educationLevelId,
    };
  }
}
