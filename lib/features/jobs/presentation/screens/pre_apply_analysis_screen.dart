import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/pre_apply_analysis.dart';
import '../bloc/pre_apply_bloc.dart';
import '../bloc/pre_apply_event.dart';
import '../bloc/pre_apply_state.dart';

class PreApplyAnalysisScreen extends StatelessWidget {
  final String jobSlug;
  final String jobTitle;
  final String? coverLetter;
  final Map<String, dynamic>? screeningResponses;
  final int? cvOptimizationId;

  const PreApplyAnalysisScreen({
    Key? key,
    required this.jobSlug,
    required this.jobTitle,
    this.coverLetter,
    this.screeningResponses,
    this.cvOptimizationId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = sl<PreApplyBloc>();
        // If we have content to analyse, run fresh analysis; otherwise load existing
        if (coverLetter != null || screeningResponses != null) {
          bloc.add(RunAnalysisEvent(
            jobSlug: jobSlug,
            coverLetter: coverLetter,
            screeningResponses: screeningResponses,
            cvOptimizationId: cvOptimizationId,
          ));
        } else {
          bloc.add(LoadExistingAnalysisEvent(jobSlug));
        }
        return bloc;
      },
      child: _PreApplyAnalysisView(jobSlug: jobSlug, jobTitle: jobTitle),
    );
  }
}

class _PreApplyAnalysisView extends StatelessWidget {
  final String jobSlug;
  final String jobTitle;
  const _PreApplyAnalysisView({required this.jobSlug, required this.jobTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Analysis'),
        centerTitle: false,
      ),
      body: BlocBuilder<PreApplyBloc, PreApplyState>(
        builder: (context, state) {
          if (state is PreApplyLoading || state is PreApplyInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PreApplyAnalyzing) {
            return const _AnalyzingView();
          }

          if (state is PreApplyNoExisting) {
            return _buildRunPrompt(context);
          }

          if (state is PreApplyError) {
            return _buildError(context, state);
          }

          if (state is PreApplyLoaded) {
            return _buildResults(context, state.analysis);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildRunPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.analytics_outlined, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No analysis yet for this job',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Go to the apply form, fill in your cover letter and screening answers, then tap "Analyze My Application" to get AI-powered feedback.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('Back to Job'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, PreApplyError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              state.isSubscriptionRequired ? Icons.lock_outline : Icons.error_outline,
              size: 64,
              color: state.isSubscriptionRequired ? AppTheme.primaryColor : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              state.isSubscriptionRequired
                  ? 'Subscription Required'
                  : 'Analysis Failed',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.isSubscriptionRequired
                  ? 'Pre-application analysis is a premium feature. Upgrade your plan to access it.'
                  : state.message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            if (state.isSubscriptionRequired)
              ElevatedButton(
                onPressed: () => context.push('/subscription'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('View Plans'),
              )
            else
              ElevatedButton(
                onPressed: () => context.read<PreApplyBloc>().add(
                      RunAnalysisEvent(jobSlug: jobSlug),
                    ),
                child: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context, PreApplyAnalysis analysis) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score card
          _ScoreCard(analysis: analysis),
          const SizedBox(height: 16),

          // Shortlist likelihood
          _InfoCard(
            icon: Icons.flag_outlined,
            title: 'Shortlist Likelihood',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LikelihoodBadge(analysis.shortlistLikelihood),
                const SizedBox(height: 8),
                Text(analysis.shortlistReasoning),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Summary
          _InfoCard(
            icon: Icons.summarize_outlined,
            title: 'Summary',
            child: Text(analysis.screeningSummary),
          ),
          const SizedBox(height: 16),

          // Improvement tips
          if (analysis.improvementTips.isNotEmpty)
            _InfoCard(
              icon: Icons.lightbulb_outline,
              title: 'Improvement Tips',
              child: Column(
                children: analysis.improvementTips
                    .map((tip) => _BulletPoint(tip, color: AppTheme.primaryColor))
                    .toList(),
              ),
            ),
          const SizedBox(height: 16),

          // Matched keywords
          if (analysis.matchedKeywords.isNotEmpty)
            _InfoCard(
              icon: Icons.check_circle_outline,
              title: 'Matched Keywords',
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: analysis.matchedKeywords
                    .map((kw) => _KeywordChip(kw, matched: true))
                    .toList(),
              ),
            ),
          const SizedBox(height: 16),

          // Missing keywords
          if (analysis.missingKeywords.isNotEmpty)
            _InfoCard(
              icon: Icons.highlight_off,
              title: 'Missing Keywords',
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: analysis.missingKeywords
                    .map((kw) => _KeywordChip(kw, matched: false))
                    .toList(),
              ),
            ),
          const SizedBox(height: 16),

          // Strengths & weaknesses
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (analysis.pros.isNotEmpty)
                Expanded(
                  child: _InfoCard(
                    icon: Icons.thumb_up_outlined,
                    title: 'Strengths',
                    child: Column(
                      children: analysis.pros
                          .map((p) => _BulletPoint(p, color: Colors.green))
                          .toList(),
                    ),
                  ),
                ),
              if (analysis.pros.isNotEmpty && analysis.cons.isNotEmpty)
                const SizedBox(width: 12),
              if (analysis.cons.isNotEmpty)
                Expanded(
                  child: _InfoCard(
                    icon: Icons.thumb_down_outlined,
                    title: 'Weaknesses',
                    child: Column(
                      children: analysis.cons
                          .map((c) => _BulletPoint(c, color: Colors.red))
                          .toList(),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Re-analyze button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.read<PreApplyBloc>().add(
                    RunAnalysisEvent(jobSlug: jobSlug),
                  ),
              icon: const Icon(Icons.refresh),
              label: const Text('Re-analyze'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Back to Application'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyzingView extends StatelessWidget {
  const _AnalyzingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'Analyzing your application...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Our AI is reviewing your profile and application against the job requirements.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final PreApplyAnalysis analysis;
  const _ScoreCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final color = analysis.scoreColor;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: analysis.score / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeWidth: 8,
                  ),
                  Center(
                    child: Text(
                      '${analysis.score}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Application Score',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    'Ranking: ${analysis.rankingScore}/10',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Recommendation: ${analysis.recommendation}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _InfoCard({required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  final Color color;
  const _BulletPoint(this.text, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _KeywordChip extends StatelessWidget {
  final String keyword;
  final bool matched;
  const _KeywordChip(this.keyword, {required this.matched});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(keyword, style: const TextStyle(fontSize: 12)),
      backgroundColor: matched ? Colors.green.shade50 : Colors.red.shade50,
      side: BorderSide(
        color: matched ? Colors.green.shade300 : Colors.red.shade300,
      ),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _LikelihoodBadge extends StatelessWidget {
  final String likelihood;
  const _LikelihoodBadge(this.likelihood);

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (likelihood.toLowerCase()) {
      case 'high':
        color = Colors.green;
        break;
      case 'medium':
        color = Colors.amber.shade700;
        break;
      default:
        color = Colors.red;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        likelihood,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
