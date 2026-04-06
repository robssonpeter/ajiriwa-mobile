import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/bloc.dart';
import '../../domain/entities/dashboard.dart';
import '../bloc/bloc.dart';

/// Dashboard screen - the main screen of the app
class DashboardScreen extends StatelessWidget {
  /// Constructor
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is Authenticated) {
          context.read<DashboardBloc>().add(LoadDashboardEvent());
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is Authenticated) {
            final user = authState.user;

            return Scaffold(
              backgroundColor: Colors.grey.shade50,
              body: SafeArea(
                child: BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, state) {
                    if (state is DashboardLoading) {
                      return _buildSkeletonDashboard();
                    } else if (state is DashboardLoaded) {
                      final dashboard = state.dashboard;
                      return _buildDashboardContent(context, user.name, dashboard, user);
                    } else if (state is DashboardError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error: ${state.message}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<DashboardBloc>().add(LoadDashboardEvent());
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Initial state, show loading
                    return _buildSkeletonDashboard();
                  }
                },
              ),
            ),
          );
        } else if (authState is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          // If not authenticated, the router will redirect to login
          Future.microtask(() => context.goNamed(AppRouter.login));
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, String userName, Dashboard dashboard, User user) {
    final firstName = userName.split(' ').first;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Switcher (Compact)
          if (user.candidates != null && user.candidates!.length > 1) ...[
            _buildProfileSwitcherCompact(context, user),
            const SizedBox(height: 24),
          ],

          // Greeting section
          Text(
            'Good Afternoon,',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          Text(
            firstName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),

          // Quick Action Cards
          _buildQuickActionsGrid(context),
          const SizedBox(height: 32),

          // Auto-Apply Status Card
          if (dashboard.autoApplySettings != null) ...[
            _buildAutoApplyStatusCard(context, dashboard),
            const SizedBox(height: 32),
          ],

          // Profile completion card (as a fallback or secondary info)
          if (dashboard.profileCompletion.percentage < 100) ...[
            _buildProfileCompletionCard(context, dashboard.profileCompletion),
            const SizedBox(height: 32),
          ],

          // Recommended jobs section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recommended Jobs',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.goNamed('jobs'),
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRecommendedJobsList(dashboard.recommendedJobs),
          const SizedBox(height: 32),

          // Recent applications section
          const Text(
            'Recent Applications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentApplicationsList(dashboard.recentApplications),
        ],
      ),
    );
  }

  Widget _buildProfileSwitcherCompact(BuildContext context, User user) {
    final selectedCandidate = user.candidates?.firstWhere(
      (c) => c['id'] == user.selectedCandidateId,
      orElse: () => user.candidates!.first,
    );

    return InkWell(
      onTap: () {
        _showProfileSelectionSheet(context, user);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.person, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Profile',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    selectedCandidate?['label'] ?? 'Default CV',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.swap_horiz, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }

  void _showProfileSelectionSheet(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Switch Profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: user.candidates!.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final candidate = user.candidates![index];
                      final isSelected = candidate['id'] == user.selectedCandidateId;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected 
                              ? AppTheme.primaryColor.withOpacity(0.1)
                              : Colors.grey.shade100,
                          child: Icon(
                            Icons.person,
                            color: isSelected ? AppTheme.primaryColor : Colors.grey,
                          ),
                        ),
                        title: Text(
                          candidate['label'] ?? 'CV #${candidate['id']}',
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: candidate['title'] != null ? Text(candidate['title']) : null,
                        trailing: isSelected 
                            ? const Icon(Icons.check_circle, color: AppTheme.primaryColor)
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          if (!isSelected) {
                            context.read<AuthBloc>().add(SwitchCandidateEvent(candidate['id']));
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.9,
      children: [
        _buildQuickActionCard(
          context,
          icon: Icons.person_outline,
          label: 'My Profile',
          onTap: () => context.goNamed(AppRouter.profile),
        ),
        _buildQuickActionCard(
          context,
          icon: Icons.work_outline,
          label: 'Browse Jobs',
          onTap: () => context.goNamed('jobs'),
        ),
        _buildQuickActionCard(
          context,
          icon: Icons.edit_note,
          label: 'Update Profile',
          onTap: () => context.pushNamed('resume_edit'),
        ),
        _buildQuickActionCard(
          context,
          icon: Icons.send_outlined,
          label: 'Applications',
          onTap: () => context.goNamed('applications'),
        ),
        _buildQuickActionCard(
          context,
          icon: Icons.description_outlined,
          label: 'CV Assistant',
          onTap: () => context.pushNamed('cv_builder'),
        ),
        _buildQuickActionCard(
          context,
          icon: Icons.bolt,
          label: 'Auto-Apply',
          onTap: () => context.pushNamed('auto_apply'),
        ),
        _buildQuickActionCard(
          context,
          icon: Icons.auto_fix_high_rounded,
          label: 'CV Optimizer',
          onTap: () => context.pushNamed(AppRouter.cvOptimization),
        ),
        _buildQuickActionCard(
          context,
          icon: Icons.workspace_premium_rounded,
          label: 'Subscription',
          onTap: () => context.pushNamed(AppRouter.subscription),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoApplyStatusCard(BuildContext context, Dashboard dashboard) {
    final isEnabled = dashboard.autoApplySettings?.enabled ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Auto-Apply Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isEnabled ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isEnabled ? Colors.green : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isEnabled ? 'Active' : 'Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isEnabled ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildStatItem(
                      context,
                      icon: Icons.search,
                      color: Colors.blue,
                      label: 'Jobs Found',
                      value: dashboard.jobMatchCount.toString(),
                      sublabel: 'Matching criteria',
                    ),
                    _buildStatItem(
                      context,
                      icon: Icons.check_circle_outline,
                      color: Colors.green,
                      label: 'Jobs Applied',
                      value: dashboard.autoAppliedCount.toString(),
                      sublabel: 'Automatically',
                    ),
                    _buildStatItem(
                      context,
                      icon: Icons.bar_chart,
                      color: Colors.purple,
                      label: 'Success Rate',
                      value: '28%', // Hardcoded for now as in web
                      sublabel: 'Responses',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade100),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextButton.icon(
              onPressed: () => context.pushNamed('auto_apply'),
              icon: const Icon(Icons.settings, size: 18),
              label: const Text('Manage Auto-Apply'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required String sublabel,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 14),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            sublabel,
            style: TextStyle(
              fontSize: 8,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletionCard(BuildContext context, ProfileCompletion profileCompletion) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Profile Completion',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${profileCompletion.percentage}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: profileCompletion.percentage / 100,
              minHeight: 8,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
          if (profileCompletion.missingSections.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Missing: ${profileCompletion.missingSections.join(', ')}',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.goNamed(AppRouter.profile),
            child: const Text('Complete Your Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedJobsList(List<RecommendedJob> jobs) {
    if (jobs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text('No recommended jobs found'),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                if (job.slug != null) {
                  context.pushNamed(
                    'job_view',
                    pathParameters: {'slug': job.slug!},
                  );
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      job.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _buildCompanyLogo(job.company, size: 60),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      job.company.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'New',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentApplicationsList(List<RecentApplication> applications) {
    if (applications.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text('No recent applications found'),
        ),
      );
    }

    return Column(
      children: applications.map((application) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: application.job != null 
                ? _buildCompanyLogo(application.job!.company, size: 48)
                : CircleAvatar(
                    backgroundColor: Colors.grey.shade100,
                    child: const Icon(Icons.work_outline, color: Colors.grey),
                  ),
            title: Text(
              application.job?.title ?? 'Job no longer available',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Row(
              children: [
                Text(
                  'Status: ',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                Text(
                  _getStatusText(application.status),
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(application.status),
                  ),
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              // Navigate to application details
            },
          ),
        );
      }).toList(),
    );
  }

  String _getStatusText(int status) {
    switch (status) {
      case 1: return 'Submitted';
      case 2: return 'In Review';
      case 3: return 'Rejected';
      case 4: return 'Accepted';
      default: return 'Unknown';
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1: return Colors.blue;
      case 2: return Colors.orange;
      case 3: return Colors.red;
      case 4: return Colors.green;
      default: return Colors.grey;
    }
  }

  Widget _buildCompanyLogo(Company company, {double size = 40}) {
    final logoUrl = company.effectiveLogoUrl;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: logoUrl != null
            ? Image.network(
                logoUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(company.name),
              )
            : _buildPlaceholder(company.name),
      ),
    );
  }

  Widget _buildSkeletonDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _skeletonBox(height: 60, borderRadius: 12),
          const SizedBox(height: 24),
          _skeletonBox(height: 32, width: 160),
          const SizedBox(height: 8),
          _skeletonBox(height: 32, width: 120),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9,
            children: List.generate(6, (_) => _skeletonBox(borderRadius: 16)),
          ),
          const SizedBox(height: 32),
          _skeletonBox(height: 140, borderRadius: 20),
          const SizedBox(height: 32),
          _skeletonBox(height: 24, width: 180),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => _skeletonBox(width: 200, borderRadius: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonBox({double? width, double? height, double borderRadius = 8}) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  Widget _buildPlaceholder(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
