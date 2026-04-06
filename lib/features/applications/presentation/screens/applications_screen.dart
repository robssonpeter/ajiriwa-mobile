import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../bloc/applications_bloc.dart';
import '../bloc/applications_event.dart';
import '../bloc/applications_state.dart';
import '../../../../core/navigation/app_router.dart';

/// Applications screen - shows the user's job applications and their statuses
class ApplicationsScreen extends StatelessWidget {
  /// Constructor
  const ApplicationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ApplicationsBloc>()..add(const LoadApplicationsEvent()),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('My Applications'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'All'),
                Tab(text: 'Active'),
                Tab(text: 'Archived'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildApplicationsList(context, 'all'),
              _buildApplicationsList(context, 'active'),
              _buildApplicationsList(context, 'archived'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApplicationsList(BuildContext context, String filter) {
    return BlocBuilder<ApplicationsBloc, ApplicationsState>(
      builder: (context, state) {
        if (state is ApplicationsInitial) {
          // Trigger loading if in initial state
          context.read<ApplicationsBloc>().add(const LoadApplicationsEvent());
          return _buildSkeletonApplicationsList();
        } else if (state is ApplicationsLoading) {
          return _buildSkeletonApplicationsList();
        } else if (state is ApplicationsError) {
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
                    context.read<ApplicationsBloc>().add(const LoadApplicationsEvent());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (state is ApplicationsLoaded || state is ApplicationsLoadingMore) {
          final applications = state is ApplicationsLoaded
              ? state.applications
              : (state as ApplicationsLoadingMore).applications;

          // Filter applications based on the selected tab
          final filteredApplications = applications.where((app) {
            if (filter == 'all') return true;
            if (filter == 'active') {
              return app.applicationStatus != 'Drafted';
            }
            if (filter == 'archived') {
              return app.applicationStatus == 'Drafted';
            }
            return false;
          }).toList();

          if (filteredApplications.isEmpty) {
            return _buildEmptyState(context, filter);
          }

          return Stack(
            children: [
              // Applications list
              NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo is ScrollEndNotification &&
                      scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent * 0.9 &&
                      state.hasMore &&
                      state is! ApplicationsLoadingMore) {
                    // Load more applications when user scrolls to 90% of the list
                    context.read<ApplicationsBloc>().add(LoadMoreApplicationsEvent());
                  }
                  return false;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredApplications.length + (state.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Show loading indicator at the bottom when loading more
                    if (index == filteredApplications.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final application = filteredApplications[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: InkWell(
                        onTap: () {
                          // TODO: Navigate to application details
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          application.jobTitle,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          application.companyName,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _buildStatusChip(context, application.applicationStatus),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Applied on: ${application.appliedOn} (${application.timeAgo})',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  icon: const Icon(Icons.visibility, size: 16),
                                  label: const Text('View Details'),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () {
                                    context.pushNamed(
                                      AppRouter.applicationView,
                                      pathParameters: {'id': application.applicationId.toString()},
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              ),
              // Show loading overlay when loading more
              if (state is ApplicationsLoadingMore) ...[
                const Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(),
                ),
              ]
            ],
          );
        }

        // Fallback
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color chipColor;
    Color textColor = Colors.white;

    // STATUS mapping:
    // 0 => 'Drafted'
    // 1 => 'Applied'
    // 2 => 'Rejected'
    // 3 => 'Shortlisted'
    // 4 => 'To be interviewed'
    // 5 => 'Interviewed'
    // 6 => 'Selected'

    switch (status) {
      case 'Drafted':
        chipColor = Colors.grey;
        break;
      case 'Applied':
        chipColor = Colors.blue;
        break;
      case 'Rejected':
        chipColor = Colors.red;
        break;
      case 'Shortlisted':
        chipColor = Colors.amber.shade700;
        break;
      case 'To be interviewed':
        chipColor = Colors.purple;
        break;
      case 'Interviewed':
        chipColor = Colors.deepPurple;
        break;
      case 'Selected':
        chipColor = Colors.green;
        break;
      default:
        chipColor = Colors.grey.shade600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String filter) {
    String message;
    String buttonText;
    IconData icon;

    switch (filter) {
      case 'active':
        message = 'You have no active applications';
        buttonText = 'Browse Jobs';
        icon = Icons.work_outline;
        break;
      case 'archived':
        message = 'You have no archived applications';
        buttonText = 'View All Applications';
        icon = Icons.archive_outlined;
        break;
      default:
        message = 'You haven\'t applied to any jobs yet';
        buttonText = 'Browse Jobs';
        icon = Icons.work_outline;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to jobs screen or all applications
            },
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Build a skeleton loading UI for applications list
  Widget _buildSkeletonApplicationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      physics: const NeverScrollableScrollPhysics(), // Disable scrolling
      shrinkWrap: true, // Ensure the ListView takes only the space it needs
      itemCount: 5, // Show 5 skeleton cards
      itemBuilder: (context, index) => _buildSkeletonApplicationCard(),
    );
  }

  /// Build a skeleton loading UI for a single application card
  Widget _buildSkeletonApplicationCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        width: double.infinity,
        height: 150, // Adjusted height for application card
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade400,
          highlightColor: Colors.grey.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job title and status row
                Row(
                  children: [
                    // Title placeholder
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
                    // Status chip placeholder
                    Container(
                      width: 80,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Applied date placeholder
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        height: 12,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // View details button placeholder
                    Container(
                      width: 100,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
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
