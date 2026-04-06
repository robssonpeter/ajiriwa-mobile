import '../../domain/entities/resume_data.dart';

/// Resume data model
class ResumeDataModel extends ResumeData {
  /// Constructor
  const ResumeDataModel({
    required Map<String, dynamic> template,
    required Map<String, dynamic> candidate,
    required Map<String, dynamic> sections,
    required List<Map<String, dynamic>> candidateOptions,
    required int selectedCandidateId,
  }) : super(
          template: template,
          candidate: candidate,
          sections: sections,
          candidateOptions: candidateOptions,
          selectedCandidateId: selectedCandidateId,
        );

  /// Create a model from JSON
  factory ResumeDataModel.fromJson(Map<String, dynamic> json) {
    return ResumeDataModel(
      template: json['template'] as Map<String, dynamic>,
      candidate: json['candidate'] as Map<String, dynamic>,
      sections: json['sections'] as Map<String, dynamic>,
      candidateOptions: List<Map<String, dynamic>>.from(json['candidateOptions'] as List),
      selectedCandidateId: json['selectedCandidateId'] as int,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'template': template,
      'candidate': candidate,
      'sections': sections,
      'candidateOptions': candidateOptions,
      'selectedCandidateId': selectedCandidateId,
    };
  }
}