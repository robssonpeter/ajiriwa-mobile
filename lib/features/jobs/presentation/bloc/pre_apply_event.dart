import 'package:equatable/equatable.dart';

abstract class PreApplyEvent extends Equatable {
  const PreApplyEvent();
  @override
  List<Object?> get props => [];
}

class LoadExistingAnalysisEvent extends PreApplyEvent {
  final String jobSlug;
  const LoadExistingAnalysisEvent(this.jobSlug);
  @override
  List<Object?> get props => [jobSlug];
}

class RunAnalysisEvent extends PreApplyEvent {
  final String jobSlug;
  final String? coverLetter;
  final Map<String, dynamic>? screeningResponses;
  final int? cvOptimizationId;

  const RunAnalysisEvent({
    required this.jobSlug,
    this.coverLetter,
    this.screeningResponses,
    this.cvOptimizationId,
  });

  @override
  List<Object?> get props => [jobSlug, coverLetter, screeningResponses, cvOptimizationId];
}
