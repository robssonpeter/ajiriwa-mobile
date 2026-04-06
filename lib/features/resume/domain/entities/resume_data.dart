import 'package:equatable/equatable.dart';

/// Resume data entity
class ResumeData extends Equatable {
  /// Template information
  final Map<String, dynamic> template;

  /// Candidate information
  final Map<String, dynamic> candidate;

  /// Resume sections
  final Map<String, dynamic> sections;

  /// Candidate options
  final List<Map<String, dynamic>> candidateOptions;

  /// Selected candidate ID
  final int selectedCandidateId;

  /// Constructor
  const ResumeData({
    required this.template,
    required this.candidate,
    required this.sections,
    required this.candidateOptions,
    required this.selectedCandidateId,
  });

  @override
  List<Object?> get props => [
        template,
        candidate,
        sections,
        candidateOptions,
        selectedCandidateId,
      ];
}