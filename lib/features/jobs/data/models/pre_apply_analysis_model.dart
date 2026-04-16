import '../../domain/entities/pre_apply_analysis.dart';

class PreApplyAnalysisModel extends PreApplyAnalysis {
  const PreApplyAnalysisModel({
    super.id,
    required super.score,
    required super.screeningSummary,
    required super.matchedKeywords,
    required super.missingKeywords,
    required super.rankingScore,
    required super.shortlistLikelihood,
    required super.shortlistReasoning,
    required super.improvementTips,
    required super.pros,
    required super.cons,
    required super.recommendation,
    super.draftId,
  });

  factory PreApplyAnalysisModel.fromJson(Map<String, dynamic> json) {
    final analysis = json['analysis'] as Map<String, dynamic>? ?? json;
    final analysisData = analysis['analysis_data'] as Map<String, dynamic>? ?? {};

    return PreApplyAnalysisModel(
      id: analysis['id'],
      draftId: json['draft_id'],
      score: analysis['screening_score'] ?? 0,
      screeningSummary: analysis['screening_summary'] ?? '',
      matchedKeywords: _toStringList(analysis['matched_keywords']),
      missingKeywords: _toStringList(analysis['missing_keywords']),
      rankingScore: analysis['ranking_score'] ?? 0,
      shortlistLikelihood:
          analysisData['shortlist_likelihood'] ?? analysis['shortlist_likelihood'] ?? 'Medium',
      shortlistReasoning:
          analysisData['shortlist_reasoning'] ?? analysis['shortlist_reasoning'] ?? '',
      improvementTips:
          _toStringList(analysisData['improvement_tips'] ?? analysis['improvement_tips']),
      pros: _toStringList(analysisData['pros']),
      cons: _toStringList(analysisData['cons']),
      recommendation: analysisData['recommendation'] ?? 'Moderate',
    );
  }

  static List<String> _toStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  PreApplyAnalysis toEntity() => this;
}
