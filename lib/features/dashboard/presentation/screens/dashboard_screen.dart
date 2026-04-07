import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/bloc.dart';
import '../../domain/entities/dashboard.dart';
import '../bloc/bloc.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  void initState() {
    super.initState();
    // BlocListener only fires on state *changes*. If the user is already
    // authenticated when this screen mounts (e.g. on app launch), the
    // listener never fires. We dispatch here to cover that case.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        context.read<DashboardBloc>().add(LoadDashboardEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      // Only re-trigger when auth state actually transitions to Authenticated
      // (e.g. after a login). initState handles the already-authenticated case.
      listener: (context, authState) {
        if (authState is Authenticated) {
          context.read<DashboardBloc>().add(LoadDashboardEvent());
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is Authenticated) {
            return Scaffold(
              backgroundColor: Colors.grey.shade50,
              body: SafeArea(
                child: BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, state) {
                    if (state is DashboardLoading || state is DashboardInitial) {
                      return _buildSkeleton();
                    } else if (state is DashboardLoaded) {
                      return _buildContent(context, authState.user, state.dashboard);
                    } else if (state is DashboardError) {
                      return _buildError(context, state.message);
                    }
                    return _buildSkeleton();
                  },
                ),
              ),
            );
          } else if (authState is AuthLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else {
            Future.microtask(() => context.goNamed(AppRouter.login));
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MAIN CONTENT
  // ─────────────────────────────────────────────

  Widget _buildContent(BuildContext context, User user, Dashboard dashboard) {
    final inReviewCount =
        dashboard.recentApplications.where((a) => a.status == 2).length;

    return RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: () async {
        context.read<DashboardBloc>().add(LoadDashboardEvent());
      },
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(child: _buildHeader(context, user)),

          // Profile completion banner (only when incomplete)
          if (dashboard.profileCompletion.percentage < 100)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _buildProfileCompletionBanner(
                    context, dashboard.profileCompletion),
              ),
            ),

          // Stats strip
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildStatsStrip(dashboard, inReviewCount),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Quick actions (power features not in bottom nav)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildQuickActions(context),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Profile switcher (only when multiple profiles exist)
          if (user.candidates != null && user.candidates!.length > 1) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: _buildProfileSwitcher(context, user),
              ),
            ),
          ],

          // Auto-apply card (only when configured)
          if (dashboard.autoApplySettings != null) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: _buildAutoApplyCard(context, dashboard),
              ),
            ),
          ],

          // Recommended jobs
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recommended for You',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => context.goNamed('jobs'),
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildJobCards(context, dashboard.recommendedJobs),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Recent applications
          if (dashboard.recentApplications.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Applications',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => context.goNamed('applications'),
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: _buildApplicationItem(
                      context, dashboard.recentApplications[index]),
                ),
                childCount: dashboard.recentApplications.length,
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, User user) {
    final firstName = user.name.split(' ').first;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Row(
        children: [
          _buildAvatar(user),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  firstName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (user.headline != null && user.headline!.isNotEmpty)
                  Text(
                    user.headline!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications_none_rounded,
                    size: 28, color: Colors.grey.shade700),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(User user) {
    if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(user.photoUrl!),
        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
      );
    }
    final initials = user.name
        .trim()
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppTheme.primaryColor,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // STATS STRIP
  // ─────────────────────────────────────────────

  Widget _buildStatsStrip(Dashboard dashboard, int inReviewCount) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          _buildStat(
            label: 'Applications',
            value: dashboard.recentApplications.length.toString(),
            icon: Icons.send_rounded,
            color: Colors.blue,
          ),
          _buildStatDivider(),
          _buildStat(
            label: 'In Review',
            value: inReviewCount.toString(),
            icon: Icons.access_time_rounded,
            color: Colors.orange,
          ),
          _buildStatDivider(),
          _buildStat(
            label: 'Job Matches',
            value: dashboard.jobMatchCount.toString(),
            icon: Icons.recommend_rounded,
            color: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 48, color: Colors.grey.shade100);
  }

  // ─────────────────────────────────────────────
  // QUICK ACTIONS
  // ─────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.description_outlined,
        label: 'Update CV',
        color: const Color(0xFF3B82F6),
        onTap: () => context.pushNamed('resume_edit'),
      ),
      _QuickAction(
        icon: Icons.auto_fix_high_rounded,
        label: 'CV Optimizer',
        color: const Color(0xFF8B5CF6),
        onTap: () => context.pushNamed(AppRouter.cvOptimization),
      ),
      _QuickAction(
        icon: Icons.bolt_rounded,
        label: 'Auto-Apply',
        color: const Color(0xFFF59E0B),
        onTap: () => context.pushNamed('auto_apply'),
      ),
      _QuickAction(
        icon: Icons.workspace_premium_rounded,
        label: 'Premium',
        color: const Color(0xFFEC4899),
        onTap: () => context.pushNamed(AppRouter.subscription),
      ),
    ];

    return Row(
      children: actions.asMap().entries.map((entry) {
        final isLast = entry.key == actions.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 12),
            child: _buildQuickActionTile(entry.value),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActionTile(_QuickAction action) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: action.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: action.color.withOpacity(0.15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(action.icon, color: action.color, size: 26),
            const SizedBox(height: 6),
            Text(
              action.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: action.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // PROFILE COMPLETION BANNER
  // ─────────────────────────────────────────────

  Widget _buildProfileCompletionBanner(
      BuildContext context, ProfileCompletion pc) {
    final accentColor =
        pc.percentage < 50 ? Colors.orange : AppTheme.primaryColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: pc.percentage / 100,
                  strokeWidth: 4,
                  backgroundColor: accentColor.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
                Text(
                  '${pc.percentage}%',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete your profile',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey.shade800,
                  ),
                ),
                if (pc.missingSections.isNotEmpty)
                  Text(
                    'Missing: ${pc.missingSections.take(2).join(', ')}${pc.missingSections.length > 2 ? ' +${pc.missingSections.length - 2} more' : ''}',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
              ],
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: accentColor,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => context.pushNamed('resume_edit'),
            child: const Text('Fix', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // PROFILE SWITCHER
  // ─────────────────────────────────────────────

  Widget _buildProfileSwitcher(BuildContext context, User user) {
    final selectedCandidate = user.candidates?.firstWhere(
      (c) => c['id'] == user.selectedCandidateId,
      orElse: () => user.candidates!.first,
    );

    return InkWell(
      onTap: () => _showProfileSelectionSheet(context, user),
      borderRadius: BorderRadius.circular(12),
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
                  const Text('Active Profile',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Switch Profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: user.candidates!.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final candidate = user.candidates![index];
                    final isSelected =
                        candidate['id'] == user.selectedCandidateId;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSelected
                            ? AppTheme.primaryColor.withOpacity(0.1)
                            : Colors.grey.shade100,
                        child: Icon(Icons.person,
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey),
                      ),
                      title: Text(
                        candidate['label'] ?? 'CV #${candidate['id']}',
                        style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal),
                      ),
                      subtitle: candidate['title'] != null
                          ? Text(candidate['title'])
                          : null,
                      trailing: isSelected
                          ? const Icon(Icons.check_circle,
                              color: AppTheme.primaryColor)
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        if (!isSelected) {
                          context
                              .read<AuthBloc>()
                              .add(SwitchCandidateEvent(candidate['id']));
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // AUTO-APPLY CARD
  // ─────────────────────────────────────────────

  Widget _buildAutoApplyCard(BuildContext context, Dashboard dashboard) {
    final isEnabled = dashboard.autoApplySettings?.enabled ?? false;
    final statusColor = isEnabled ? Colors.green : Colors.red;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bolt_rounded,
                      color: Colors.amber, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Auto-Apply',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isEnabled ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade100),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                _buildAutoStat(Icons.search_rounded, Colors.blue, 'Found',
                    dashboard.jobMatchCount.toString()),
                _buildAutoStat(Icons.check_circle_outline_rounded, Colors.green,
                    'Applied', dashboard.autoAppliedCount.toString()),
                _buildAutoStat(Icons.bar_chart_rounded, Colors.purple,
                    'Success', '28%'),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade100),
          TextButton.icon(
            onPressed: () => context.pushNamed('auto_apply'),
            icon: const Icon(Icons.settings_outlined, size: 16),
            label: const Text('Manage Auto-Apply'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoStat(
      IconData icon, Color color, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // RECOMMENDED JOBS
  // ─────────────────────────────────────────────

  Widget _buildJobCards(BuildContext context, List<RecommendedJob> jobs) {
    if (jobs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(Icons.work_off_outlined,
                  size: 40, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                'No recommendations yet',
                style: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'Complete your profile to get matches',
                style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 196,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: jobs.length,
        itemBuilder: (context, index) => _buildJobCard(context, jobs[index]),
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, RecommendedJob job) {
    final salary = (job.minSalary != null && job.maxSalary != null)
        ? 'TZS ${_formatSalary(job.minSalary!)}–${_formatSalary(job.maxSalary!)}'
        : null;

    return GestureDetector(
      onTap: () {
        if (job.slug != null) {
          context.pushNamed('job_view', pathParameters: {'slug': job.slug!});
        }
      },
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildCompanyLogo(job.company, size: 38),
                const Spacer(),
                _buildBadge(
                  job.isApplied ? 'Applied' : 'New',
                  job.isApplied ? Colors.blue : AppTheme.primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              job.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              job.company.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    job.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ),
              ],
            ),
            if (salary != null) ...[
              const SizedBox(height: 4),
              Text(
                salary,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatSalary(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toString();
  }

  // ─────────────────────────────────────────────
  // RECENT APPLICATIONS
  // ─────────────────────────────────────────────

  Widget _buildApplicationItem(
      BuildContext context, RecentApplication application) {
    final statusColor = _getStatusColor(application.status);
    final statusText = _getStatusText(application.status);

    return InkWell(
      onTap: () => context.pushNamed(
        AppRouter.applicationView,
        pathParameters: {'id': application.id.toString()},
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            application.job != null
                ? _buildCompanyLogo(application.job!.company, size: 44)
                : Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.work_outline, color: Colors.grey),
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    application.job?.title ?? 'Job no longer available',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    application.job?.company.name ?? '',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(application.appliedAt),
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ERROR STATE
  // ─────────────────────────────────────────────

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<DashboardBloc>().add(LoadDashboardEvent()),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SKELETON / LOADING
  // ─────────────────────────────────────────────

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _shimmerBox(width: 48, height: 48, borderRadius: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(width: 80, height: 12),
                    const SizedBox(height: 6),
                    _shimmerBox(width: 140, height: 20),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _shimmerBox(height: 88, borderRadius: 16),
            const SizedBox(height: 24),
            Row(
              children: List.generate(
                4,
                (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 3 ? 12 : 0),
                    child: _shimmerBox(height: 72, borderRadius: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _shimmerBox(width: 180, height: 18),
            const SizedBox(height: 12),
            SizedBox(
              height: 196,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, __) =>
                    _shimmerBox(width: 220, height: 196, borderRadius: 16),
              ),
            ),
            const SizedBox(height: 24),
            _shimmerBox(width: 160, height: 18),
            const SizedBox(height: 12),
            ...List.generate(
              3,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _shimmerBox(height: 72, borderRadius: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(
      {double? width, double? height, double borderRadius = 8}) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SHARED HELPERS
  // ─────────────────────────────────────────────

  Widget _buildCompanyLogo(Company company, {double size = 40}) {
    final logoUrl = company.effectiveLogoUrl;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: logoUrl != null
            ? Image.network(
                logoUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    _buildLogoPlaceholder(company.name),
              )
            : _buildLogoPlaceholder(company.name),
      ),
    );
  }

  Widget _buildLogoPlaceholder(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          color: Colors.grey.shade400,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date).inDays;
      if (diff == 0) return 'Today';
      if (diff == 1) return 'Yesterday';
      if (diff < 7) return '$diff days ago';
      if (diff < 30) return '${(diff / 7).floor()} weeks ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 1:
        return 'Submitted';
      case 2:
        return 'In Review';
      case 3:
        return 'Rejected';
      case 4:
        return 'Accepted';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      case 4:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
