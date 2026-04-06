import 'package:equatable/equatable.dart';

import '../../domain/entities/resume_section_response.dart';

/// Resume section response model
class ResumeSectionResponseModel extends ResumeSectionResponse {
  /// Constructor
  const ResumeSectionResponseModel({
    required String section,
    required Map<String, dynamic> countries,
    required List<Map<String, dynamic>> industries,
    required Map<String, dynamic> data,
    required List<Map<String, dynamic>> candidateOptions,
    required int selectedCandidateId,
  }) : super(
          section: section,
          countries: countries,
          industries: industries,
          data: data,
          candidateOptions: candidateOptions,
          selectedCandidateId: selectedCandidateId,
        );

  /// Create a model from JSON
  factory ResumeSectionResponseModel.fromJson(Map<String, dynamic> json) {
    return ResumeSectionResponseModel(
      section: json['section'] != null ? json['section'] as String : 'personal',
      countries: json['countries'] as Map<String, dynamic>,
      industries: List<Map<String, dynamic>>.from(json['industries'] as List),
      data: json['data'] as Map<String, dynamic>,
      candidateOptions: List<Map<String, dynamic>>.from(json['candidateOptions'] as List),
      selectedCandidateId: json['selectedCandidateId'] as int,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'section': section,
      'countries': countries,
      'industries': industries,
      'data': data,
      'candidateOptions': candidateOptions,
      'selectedCandidateId': selectedCandidateId,
    };
  }
}
