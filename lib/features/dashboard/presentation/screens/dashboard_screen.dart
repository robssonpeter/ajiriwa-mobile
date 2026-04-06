import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../auth/presentation/bloc/bloc.dart';
import '../../domain/entities/dashboard.dart';
import '../bloc/bloc.dart';

/// Dashboard screen - the main screen of the app
class DashboardScreen extends StatelessWidget {
  /// Constructor
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is Authenticated) {
          final user = authState.user;

          // Load dashboard data when authenticated
          context.read<DashboardBloc>().add(LoadDashboardEvent());

          return Scaffold(
            appBar: AppBar(
              title: const Text('Dashboard'),
            ),
            body: SafeArea(
              child: BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, state) {
                  if (state is DashboardLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is DashboardLoaded) {
                    final dashboard = state.dashboard;
                    return _buildDashboardContent(context, user.name, dashboard);
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
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
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
    );
  }

  Widget _buildDashboardContent(BuildContext context, String userName, Dashboard dashboard) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting section
          Text(
            'Hello, $userName!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Welcome to Ajiriwa',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          // Profile completion card
          _buildProfileCompletionCard(context, dashboard.profileCompletion),
          const SizedBox(height: 24),

          // Recommended jobs section
          const Text(
            'Recommended Jobs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecommendedJobsList(dashboard.recommendedJobs),
          const SizedBox(height: 24),

          // Recent applications section
          const Text(
            'Recent Applications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecentApplicationsList(dashboard.recentApplications),
        ],
      ),
    );
  }

  Widget _buildProfileCompletionCard(BuildContext context, ProfileCompletion profileCompletion) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile Completion',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: profileCompletion.percentage / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text('${profileCompletion.percentage}% Complete'),
            if (profileCompletion.missingSections.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Missing: ${profileCompletion.missingSections.join(', ')}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to profile screen
                context.goNamed(AppRouter.profile);
              },
              child: const Text('Complete Your Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedJobsList(List<RecommendedJob> jobs) {
    if (jobs.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No recommended jobs found'),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: _buildCompanyLogo(job.company),
            title: Text(job.title),
            subtitle: Text('${job.company.name} • ${job.location}'),
            trailing: IconButton(
              icon: Icon(
                job.isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: job.isSaved ? Theme.of(context).colorScheme.primary : null,
              ),
              onPressed: () {
                // TODO: Implement save job functionality
              },
            ),
            onTap: () {
              // Navigate to job details screen with the job slug
              if (job.slug != null) {
                context.pushNamed(
                  'job_view',
                  pathParameters: {'slug': job.slug!},
                );
              } else {
                // Show error message if slug is not available
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Job details not available'),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildRecentApplicationsList(List<RecentApplication> applications) {
    if (applications.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No recent applications found'),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        final application = applications[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: application.job != null 
                ? _buildCompanyLogo(application.job!.company)
                : CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(Icons.work_outline, color: Colors.grey),
                  ),
            title: application.job != null 
                ? Text(application.job!.title)
                : const Text('Job no longer available'),
            subtitle: Text('Status: ${_getStatusText(application.status)}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to application details
            },
          ),
        );
      },
    );
  }

  String _getStatusText(int status) {
    // Convert status code to readable string
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

  Widget _buildCompanyLogo(Company company) {
    final logoUrl = company.effectiveLogoUrl;

    if (logoUrl == null) {
      // Display a placeholder if no logo URL is available
      return CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        child: Text(
          company.name.isNotEmpty ? company.name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      // Display the company logo
      return CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: NetworkImage(logoUrl),
        onBackgroundImageError: (exception, stackTrace) {
          // Handle image loading errors
          print('Error loading company logo: $exception');
        },
      );
    }
  }
}
