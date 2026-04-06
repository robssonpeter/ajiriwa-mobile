import '../../domain/entities/experience.dart';

/// Work experience model for resume
class ExperienceModel extends Experience {
  /// Constructor
  const ExperienceModel({
    int? id,
    required String jobTitle,
    required String company,
    required String startDate,
    String? endDate,
    required bool isCurrent,
    String? description,
    String? location,
  }) : super(
          id: id,
          jobTitle: jobTitle,
          company: company,
          startDate: startDate,
          endDate: endDate,
          isCurrent: isCurrent,
          description: description,
          location: location,
        );

  /// Create a model from JSON
  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: json['id'] as int?,
      jobTitle: json['title'] as String? ?? json['jobTitle'] as String? ?? '',
      company: json['company'] as String? ?? '',
      startDate: json['start_date'] as String? ?? json['startDate'] as String? ?? '',
      endDate: json['end_date'] as String? ?? json['endDate'] as String?,
      isCurrent: json['currently_working'] as bool? ?? json['isCurrent'] as bool? ?? false,
      description: json['description'] as String?,
      location: json['country_id'] as String? ?? json['location'] as String?,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': jobTitle,
      'company': company,
      'start_date': startDate,
      'end_date': endDate,
      'currently_working': isCurrent ? 1 : 0, // Convert boolean to integer (1 for true, 0 for false)
      'description': description,
      'country_id': location?.isNotEmpty == true ? location?.toUpperCase() : location,
      // Add industry_id as null since it's not in our model but expected by backend
      'industry_id': null,
    };
  }
}
