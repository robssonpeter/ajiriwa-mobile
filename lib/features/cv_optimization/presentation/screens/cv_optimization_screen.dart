import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/cv_optimization.dart';
import '../bloc/cv_optimization_bloc.dart';
import '../bloc/cv_optimization_event.dart';
import '../bloc/cv_optimization_state.dart';
import 'subscription_screen.dart';

class CvOptimizationScreen extends StatefulWidget {
  final int? jobId;
  final String? jobTitle;
  final String? companyName;

  const CvOptimizationScreen({
    super.key,
    this.jobId,
    this.jobTitle,
    this.companyName,
  });

  @override
  State<CvOptimizationScreen> createState() => _CvOptimizationScreenState();
}

class _CvOptimizationScreenState extends State<CvOptimizationScreen> {
  final TextEditingController _refinementController = TextEditingController();
  Timer? _pollTimer;
  int? _pollingOptimizationId;

  @override
  void initState() {
    super.initState();
    _loadOptimizations();
  }

  void _loadOptimizations() {
    if (widget.jobId != null) {
      context.read<CvOptimizationBloc>().add(LoadOptimizationsForJob(widget.jobId!));
    } else {
      context.read<CvOptimizationBloc>().add(const LoadOptimizations());
    }
  }

  void _startPolling(int optimizationId) {
    _pollingOptimizationId = optimizationId;
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        context.read<CvOptimizationBloc>().add(PollPdfStatus(optimizationId));
      }
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _pollingOptimizationId = null;
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _refinementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CV Optimization',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
            if (widget.jobTitle != null)
              Text(widget.jobTitle!,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.w400)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF6B7280)),
            onPressed: _loadOptimizations,
          ),
        ],
      ),
      body: BlocConsumer<CvOptimizationBloc, CvOptimizationState>(
        listener: (context, state) {
          if (state is CvOptimizationCreated) {
            if (state.optimization.isProcessing) {
              _startPolling(state.optimization.id);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Optimization started! This may take ~30 seconds.'),
                backgroundColor: AppTheme.primaryColor,
              ),
            );
            _loadOptimizations();
          } else if (state is CvOptimizationPdfReady) {
            _stopPolling();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PDF is ready to download!'),
                backgroundColor: AppTheme.primaryColor,
              ),
            );
            _loadOptimizations();
          } else if (state is CvOptimizationDeleted) {
            _loadOptimizations();
          } else if (state is CvOptimizationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is CvOptimizationLoading) return _buildSkeleton();

          final optimizations = state is CvOptimizationsLoaded
              ? state.optimizations
              : state is CvOptimizationActionLoading
                  ? state.optimizations
                  : state is CvOptimizationError
                      ? state.optimizations
                      : <CvOptimization>[];

          final isActionLoading = state is CvOptimizationActionLoading;

          return RefreshIndicator(
            color: AppTheme.primaryColor,
            onRefresh: () async => _loadOptimizations(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context, isActionLoading)),
                if (optimizations.isEmpty)
                  SliverFillRemaining(child: _buildEmptyState())
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildOptimizationCard(context, optimizations[index]),
                        childCount: optimizations.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isLoading) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) return const SizedBox.shrink();
        final user = authState.user;
        final candidateId = user.selectedCandidateId ?? user.candidates?.first['id'] as int? ?? 0;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_fix_high_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI CV Optimizer',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                        Text('Tailor your CV to match job requirements',
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              if (widget.jobId != null) ...[
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 12),
                if (isLoading)
                  const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                else
                  _buildOptimizeButton(context, candidateId),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptimizeButton(BuildContext context, int candidateId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _refinementController,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Optional: Add refinement instructions...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
            filled: true,
            fillColor: Colors.white.withOpacity(0.15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            context.read<CvOptimizationBloc>().add(CreateOptimization(
                  jobId: widget.jobId!,
                  candidateId: candidateId,
                  refinementInstruction: _refinementController.text.trim(),
                ));
            _refinementController.clear();
          },
          icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
          label: const Text('Optimize My CV for this Job'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildOptimizationCard(BuildContext context, CvOptimization opt) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('v${opt.version}',
                      style: const TextStyle(
                          color: AppTheme.primaryColor, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (opt.jobTitle != null)
                        Text(opt.jobTitle!,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      if (opt.companyName != null)
                        Text(opt.companyName!,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                    ],
                  ),
                ),
                _buildStatusBadge(opt.status),
              ],
            ),
          ),
          if (opt.isProcessing) _buildProgressBar(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Text(
                  _formatDate(opt.createdAt),
                  style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                ),
                const Spacer(),
                if (opt.isCompleted) ...[
                  if (opt.pdfUrl != null)
                    _actionButton(
                      icon: Icons.download_rounded,
                      label: 'Download',
                      color: AppTheme.primaryColor,
                      onTap: () => _downloadPdf(context, opt),
                    )
                  else
                    _actionButton(
                      icon: Icons.picture_as_pdf_rounded,
                      label: 'Generate PDF',
                      color: const Color(0xFF3B82F6),
                      onTap: () => context.read<CvOptimizationBloc>().add(GeneratePdf(opt.id)),
                    ),
                  const SizedBox(width: 8),
                ],
                _actionButton(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
                  color: Colors.red,
                  onTap: () => _confirmDelete(context, opt.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'completed':
        color = AppTheme.primaryColor;
        label = 'Completed';
        break;
      case 'processing':
      case 'pending':
        color = const Color(0xFFF59E0B);
        label = status == 'pending' ? 'Pending' : 'Processing';
        break;
      case 'failed':
        color = Colors.red;
        label = 'Failed';
        break;
      default:
        color = Colors.grey;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AI is optimizing your CV...', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  void _downloadPdf(BuildContext context, CvOptimization opt) {
    if (opt.pdfUrl == null) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _PdfWebViewScreen(url: opt.pdfUrl!, title: 'Optimized CV v${opt.version}'),
    ));
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Optimization'),
        content: const Text('Are you sure you want to delete this CV optimization?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CvOptimizationBloc>().add(DeleteOptimization(id));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_fix_high_rounded, size: 48, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 20),
            const Text('No Optimizations Yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 8),
            Text(
              widget.jobId != null
                  ? 'Optimize your CV for this job to increase your chances of getting hired.'
                  : 'Browse jobs and optimize your CV for specific positions.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.5),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => BlocProvider.value(
                  value: context.read<CvOptimizationBloc>(),
                  child: const SubscriptionScreen(),
                )),
              ),
              icon: const Icon(Icons.workspace_premium_rounded, size: 18),
              label: const Text('View Subscription Plans'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: const BorderSide(color: AppTheme.primaryColor),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF9FAFB),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(height: 160, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
            const SizedBox(height: 16),
            ...List.generate(3, (_) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 100,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            )),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Simple WebView screen for PDF preview/download
class _PdfWebViewScreen extends StatelessWidget {
  final String url;
  final String title;

  const _PdfWebViewScreen({required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf_rounded, size: 64, color: AppTheme.primaryColor),
            const SizedBox(height: 16),
            const Text('Your optimized CV is ready!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Tap below to open the PDF',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                // URL is opened via the system browser
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.open_in_browser_rounded),
              label: const Text('Open PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
