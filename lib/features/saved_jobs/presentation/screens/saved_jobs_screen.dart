import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../jobs/presentation/bloc/bloc.dart';
import '../../../jobs/presentation/screens/apply_screen.dart';
import '../../presentation/bloc/saved_jobs_bloc.dart';
import '../../presentation/bloc/saved_jobs_event.dart';
import '../../presentation/bloc/saved_jobs_state.dart';

/// Saved Jobs screen - shows the jobs that the user has saved for later
class SavedJobsScreen extends StatelessWidget {
  /// Constructor
  const SavedJobsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SavedJobsBloc>()..add(LoadSavedJobsEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Saved Jobs'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // TODO: Implement search functionality
              },
            ),
          ],
        ),
        body: _buildSavedJobsList(context),
      ),
    );
  }

  Widget _buildSavedJobsList(BuildContext context) {
    return BlocBuilder<SavedJobsBloc, SavedJobsState>(
      builder: (context, state) {
        if (state is SavedJobsInitial) {
          // Trigger loading if in initial state
          context.read<SavedJobsBloc>().add(LoadSavedJobsEvent());
          return _buildSkeletonJobsList();
        } else if (state is SavedJobsLoading) {
          return _buildSkeletonJobsList();
        } else if (state is SavedJobsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${state.message}',
                  style: TextStyle(color: Colors.red.shade700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<SavedJobsBloc>().add(LoadSavedJobsEvent());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (state is SavedJobsLoaded) {
          final savedJobs = state.savedJobs;

          if (savedJobs.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: savedJobs.length,
            itemBuilder: (context, index) {
              final job = savedJobs[index];
              return Dismissible(
                key: Key('saved-job-${job.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (direction) {
                  // Remove job from saved jobs
                  context.read<SavedJobsBloc>().add(RemoveFromSavedJobsEvent(jobId: job.id));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${job.title} removed from saved jobs'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          // Reload saved jobs for now
                          context.read<SavedJobsBloc>().add(LoadSavedJobsEvent());
                        },
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: InkWell(
                    onTap: () {
                      // Navigate to job details screen
                      if (job.slug.isNotEmpty) {
                        context.pushNamed(
                          AppRouter.jobView,
                          pathParameters: {'slug': job.slug},
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
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: job.company.logoUrl != null && job.company.logoUrl!.isNotEmpty
                                    ? Image.network(
                                        job.company.logoUrl!,
                                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.business),
                                      )
                                    : const Icon(Icons.business),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      job.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      job.company.name,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.bookmark),
                                color: Theme.of(context).colorScheme.primary,
                                onPressed: () {
                                  // Remove job from saved jobs
                                  context.read<SavedJobsBloc>().add(RemoveFromSavedJobsEvent(jobId: job.id));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${job.title} removed from saved jobs'),
                                      action: SnackBarAction(
                                        label: 'Undo',
                                        onPressed: () {
                                          // Reload saved jobs for now
                                          context.read<SavedJobsBloc>().add(LoadSavedJobsEvent());
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildJobDetail(Icons.location_on, job.location),
                              const SizedBox(width: 16),
                              _buildJobDetail(Icons.work, job.type.name),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildJobDetail(
                                Icons.attach_money, 
                                job.minSalary != null && job.maxSalary != null
                                    ? '\$${job.minSalary}k - \$${job.maxSalary}k'
                                    : 'Salary not specified'
                              ),
                              const SizedBox(width: 16),
                              _buildJobDetail(Icons.access_time, job.timeAgo),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    // Navigate to job details screen
                                    if (job.slug.isNotEmpty) {
                                      context.pushNamed(
                                        AppRouter.jobView,
                                        pathParameters: {'slug': job.slug},
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
                                  child: const Text('View Details'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Navigate to apply screen
                                    if (job.slug.isNotEmpty) {
                                      // Create an instance of ApplyBloc
                                      final applyBloc = sl<ApplyBloc>();

                                      // Navigate to the Apply screen
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => BlocProvider.value(
                                            value: applyBloc,
                                            child: ApplyScreen(
                                              slug: job.slug,
                                              applicationMethod: 'ajiriwa',
                                              screening: null, // No screening questions initially
                                            ),
                                          ),
                                        ),
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
                                  child: const Text('Apply Now'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }

        // Fallback - use skeleton loader for any other state
        return _buildSkeletonJobsList();
      },
    );
  }

  Widget _buildJobDetail(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No saved jobs yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Jobs you save will appear here',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to jobs screen
              context.pushNamed(AppRouter.jobs);
            },
            child: const Text('Browse Jobs'),
          ),
        ],
      ),
    );
  }

  /// Build a skeleton loading UI for saved jobs list
  Widget _buildSkeletonJobsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      physics: const NeverScrollableScrollPhysics(), // Disable scrolling
      shrinkWrap: true, // Ensure the ListView takes only the space it needs
      itemCount: 5, // Show 5 skeleton cards
      itemBuilder: (context, index) => _buildSkeletonJobCard(),
    );
  }

  /// Build a skeleton loading UI for a single job card
  Widget _buildSkeletonJobCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        width: double.infinity,
        height: 210, // Adjusted height for job card
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade400,
          highlightColor: Colors.grey.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company logo and title row
                Row(
                  children: [
                    // Logo placeholder
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Title and company placeholders
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 150,
                            height: 12,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),

                    // Bookmark icon placeholder
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Location placeholder
                Row(
                  children: [
                    Container(
                      width: 120,
                      height: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 100,
                      height: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Job type and time row placeholder
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 100,
                      height: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Buttons placeholder
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
