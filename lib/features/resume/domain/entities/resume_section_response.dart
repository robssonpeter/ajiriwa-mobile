import 'package:equatable/equatable.dart';

/// Resume section response entity
class ResumeSectionResponse extends Equatable {
  /// Section name
  final String section;

  /// Map of countries
  final Map<String, dynamic> countries;

  /// List of industries
  final List<Map<String, dynamic>> industries;

  /// Resume data
  final Map<String, dynamic> data;

  /// Candidate options
  final List<Map<String, dynamic>> candidateOptions;

  /// Selected candidate ID
  final int selectedCandidateId;

  /// Constructor
  const ResumeSectionResponse({
    required this.section,
    required this.countries,
    required this.industries,
    required this.data,
    required this.candidateOptions,
    required this.selectedCandidateId,
  });

  @override
  List<Object?> get props => [
        section,
        countries,
        industries,
        data,
        candidateOptions,
        selectedCandidateId,
      ];
}
