import '../../domain/entities/career.dart';

/// Career information model for resume
class CareerModel extends Career {
  /// Constructor
  const CareerModel({
    String? jobTitle,
    String? industry,
    int? industryId,
    int? yearsOfExperience,
    String? careerLevel,
    String? salaryExpectation,
    String? careerObjective,
  }) : super(
          jobTitle: jobTitle,
          industry: industry,
          industryId: industryId,
          yearsOfExperience: yearsOfExperience,
          careerLevel: careerLevel,
          salaryExpectation: salaryExpectation,
          careerObjective: careerObjective,
        );

  /// Create a model from JSON
  factory CareerModel.fromJson(Map<String, dynamic> json) {
    return CareerModel(
      jobTitle: json['jobTitle'] as String?,
      industry: json['industry'] as String?,
      industryId: json['industryId'] as int?,
      yearsOfExperience: json['yearsOfExperience'] as int?,
      careerLevel: json['careerLevel'] as String?,
      salaryExpectation: json['salaryExpectation'] as String?,
      careerObjective: json['career_objective'] as String?,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'jobTitle': jobTitle,
      'industry': industry,
      'industryId': industryId,
      'yearsOfExperience': yearsOfExperience,
      'careerLevel': careerLevel,
      'salaryExpectation': salaryExpectation,
      'career_objective': careerObjective,
    };
  }
}
