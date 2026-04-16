import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class PreApplyAnalysis extends Equatable {
  final int? id;
  final int score;
  final String screeningSummary;
  final List<String> matchedKeywords;
  final List<String> missingKeywords;
  final int rankingScore;
  final String shortlistLikelihood;
  final String shortlistReasoning;
  final List<String> improvementTips;
  final List<String> pros;
  final List<String> cons;
  final String recommendation;
  final int? draftId;

  const PreApplyAnalysis({
    this.id,
    required this.score,
    required this.screeningSummary,
    required this.matchedKeywords,
    required this.missingKeywords,
    required this.rankingScore,
    required this.shortlistLikelihood,
    required this.shortlistReasoning,
    required this.improvementTips,
    required this.pros,
    required this.cons,
    required this.recommendation,
    this.draftId,
  });

  Color get scoreColor {
    if (score >= 75) return const Color(0xFF10B981); // green
    if (score >= 50) return const Color(0xFFF59E0B); // amber
    return const Color(0xFFEF4444); // red
  }

  @override
  List<Object?> get props => [
        id, score, screeningSummary, matchedKeywords, missingKeywords,
        rankingScore, shortlistLikelihood, shortlistReasoning,
        improvementTips, pros, cons, recommendation, draftId,
      ];
}
