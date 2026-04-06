import 'package:equatable/equatable.dart';

/// Career information entity for resume
class Career extends Equatable {
  /// Current job title
  final String? jobTitle;

  /// Industry
  final String? industry;

  /// Industry ID
  final int? industryId;

  /// Years of experience
  final int? yearsOfExperience;

  /// Career level
  final String? careerLevel;

  /// Salary expectation
  final String? salaryExpectation;

  /// Career objective (HTML format)
  final String? careerObjective;

  /// Constructor
  const Career({
    this.jobTitle,
    this.industry,
    this.industryId,
    this.yearsOfExperience,
    this.careerLevel,
    this.salaryExpectation,
    this.careerObjective,
  });

  @override
  List<Object?> get props => [
        jobTitle,
        industry,
        industryId,
        yearsOfExperience,
        careerLevel,
        salaryExpectation,
        careerObjective,
      ];
}
