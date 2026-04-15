import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/navigation/app_router.dart';
import '../../domain/entities/job_listing.dart';
import '../bloc/bloc.dart';
import '../../../../core/utils/app_logger.dart';

/// Jobs screen - allows users to browse and search for jobs
class JobsScreen extends StatefulWidget {
  /// Constructor
  const JobsScreen({Key? key}) : super(key: key);

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showFilters = false;

  // Filter values
  String? _location;
  String? _jobType;
  int? _category;
  int? _industry;
  int? _minSalary;
  int? _maxSalary;

  @override
  void initState() {
    super.initState();

    // Load jobs when the screen is first built
    context.read<JobsBloc>().add(const LoadJobsEvent());

    // Add scroll listener for infinite scrolling
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Check if we've reached the bottom of the list
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Get the current state
      final state = context.read<JobsBloc>().state;

      // Only load more if we're in a loaded state and not already loading
      if (state is JobsLoaded && !(context.read<JobsBloc>().state is JobsLoading)) {
        context.read<JobsBloc>().add(LoadMoreJobsEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Jobs'),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off : Icons.filter_list,
            ),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search jobs...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onSubmitted: (value) {
                // Search for jobs with the entered query
                context.read<JobsBloc>().add(LoadJobsEvent(query: value));
              },
            ),
          ),

          // Filters section
          if (_showFilters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      _buildFilterChip('Category', Icons.category),
                      _buildFilterChip('Type', Icons.work),
                      _buildFilterChip('Location', Icons.location_on),
                      _buildFilterChip('Salary', Icons.attach_money),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Clear all filters
                            setState(() {
                              _location = null;
                              _jobType = null;
                              _category = null;
                              _industry = null;
                              _minSalary = null;
                              _maxSalary = null;
                            });

                            // Reload jobs without filters
                            context.read<JobsBloc>().add(ClearFiltersEvent());
                          },
                          child: const Text('Clear'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Apply filters
                            context.read<JobsBloc>().add(ApplyFiltersEvent(
                              query: _searchController.text.isNotEmpty ? _searchController.text : null,
                              location: _location,
                              jobType: _jobType,
                              category: _category,
                              industry: _industry,
                              minSalary: _minSalary,
                              maxSalary: _maxSalary,
                            ));
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

          // Active filters display
          BlocBuilder<JobsBloc, JobsState>(
            builder: (context, state) {
              if (state is JobsLoaded && state.filters.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Active Filters',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: _buildActiveFilterChips(context, state.filters),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink(); // No filters active
            },
          ),

          // Jobs list
          Expanded(
            child: BlocConsumer<JobsBloc, JobsState>(
              listener: (context, state) {
                // Show error message when job save/unsave fails
                if (state is JobSaveErrorState) {
                  final action = state.wasSaving ? 'saving' : 'unsaving';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error $action job: ${state.message}'),
                      action: SnackBarAction(
                        label: 'Retry',
                        onPressed: () {
                          // Retry the operation
                          context.read<JobsBloc>().add(
                                ToggleJobSavedEvent(
                                  jobId: state.jobId,
                                  isSaved: !state.wasSaving,
                                ),
                              );
                        },
                      ),
                    ),
                  );
                }

                // Show success message when job is saved
                else if (state is JobSavedSuccessState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${state.jobTitle} added to saved jobs'),
                      backgroundColor: Colors.green,
                      action: SnackBarAction(
                        label: 'View Saved',
                        textColor: Colors.white,
                        onPressed: () {
                          // Navigate to saved jobs screen
                          context.pushNamed(AppRouter.savedJobs);
                        },
                      ),
                    ),
                  );
                }

                // Show success message when job is unsaved
                else if (state is JobUnsavedSuccessState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${state.jobTitle} removed from saved jobs'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          // Undo the unsave operation
                          context.read<JobsBloc>().add(
                                ToggleJobSavedEvent(
                                  jobId: state.jobId,
                                  isSaved: false, // It was just unsaved, so now we want to save it
                                ),
                              );
                        },
                      ),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is JobsInitial || (state is JobsLoading && state.isInitialLoad)) {
                  // Show skeleton loading indicators for initial load
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    physics: const NeverScrollableScrollPhysics(), // Disable scrolling
                    shrinkWrap: true, // Ensure the ListView takes only the space it needs
                    itemCount: 5, // Show 5 skeleton cards
                    itemBuilder: (context, index) => _buildSkeletonJobCard(),
                  );
                } else if (state is JobsLoadingMore) {
                  // Show current jobs list with skeleton loader at the bottom
                  return _buildJobsList(state, isLoadingMore: true);
                } else if (state is JobsLoaded) {
                  // Show jobs list - for saving/unsaving states, we'll handle the loading UI in the bookmark icon
                  // This ensures we don't show a full-screen loading indicator when saving/unsaving a job
                  return _buildJobsList(state);
                } else if (state is JobsError) {
                  // Show error message
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
                            // Retry loading jobs
                            context.read<JobsBloc>().add(const LoadJobsEvent());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Fallback
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsList(JobsLoaded state, {bool isLoadingMore = false}) {
    final allJobs = [...state.sponsoredJobs, ...state.jobs];

    if (allJobs.isEmpty) {
      return const Center(
        child: Text('No jobs found'),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      itemCount: allJobs.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Show skeleton loader at the bottom when loading more
        if (isLoadingMore && index == allJobs.length) {
          return Container(
            height: 200, // Fixed height for the skeleton loader
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _buildSkeletonJobCard(),
          );
        }

        // Get the job at this index
        final job = allJobs[index];

        // Check if this is a sponsored job
        final isSponsored = index < state.sponsoredJobs.length;

        // Build the job card
        return _buildJobCard(job, isSponsored);
      },
    );
  }

  Widget _buildJobCard(JobListing job, bool isSponsored) {
    // Create a card with a border if it's sponsored
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: isSponsored ? 4 : 1,
      shape: isSponsored
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2.0,
              ),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sponsored badge
            if (isSponsored)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                margin: const EdgeInsets.only(bottom: 8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Sponsored',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

            // Job header (logo, title, company)
            Row(
              children: [
                // Company logo
                _buildCompanyLogo(job.companyLogoUrl),
                const SizedBox(width: 16),

                // Job title and company
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
                        job.companyName ?? 'Unknown Company',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Bookmark button
                BlocBuilder<JobsBloc, JobsState>(
                  builder: (context, state) {
                    // Check if this job is currently being saved or unsaved
                    bool isLoading = false;
                    if ((state is JobSavingState && state.jobId == job.id) ||
                        (state is JobUnsavingState && state.jobId == job.id)) {
                      isLoading = true;
                    }

                    if (isLoading) {
                      // Show shimmer effect on bookmark icon during loading
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: IconButton(
                          icon: Icon(
                            job.isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: Colors.grey.shade400,
                          ),
                          onPressed: null, // Disable the button during loading
                        ),
                      );
                    } else {
                      // Show bookmark icon
                      return IconButton(
                        icon: Icon(
                          job.isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: job.isSaved ? Theme.of(context).colorScheme.primary : null,
                        ),
                        onPressed: () {
                          // Dispatch toggle job saved event
                          context.read<JobsBloc>().add(
                                ToggleJobSavedEvent(
                                  jobId: job.id,
                                  isSaved: job.isSaved,
                                ),
                              );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Job details (location in one row, type and time in another)
            Row(
              children: [
                Expanded(
                  child: _buildJobDetail(Icons.location_on, job.location),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildJobDetail(Icons.work, job.jobType),
                const SizedBox(width: 16),
                _buildJobDetail(Icons.access_time, job.postedTimeago),
                const SizedBox(width: 16),
                if (job.isApplied)
                  _buildJobDetail(Icons.check_circle, 'Applied', color: Colors.green),
              ],
            ),
            const SizedBox(height: 16),

            // View details button
            ElevatedButton(
              onPressed: () {
                // Navigate to job details screen
                if (job.slug != null && job.slug.isNotEmpty) {
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
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyLogo(String? logoUrl) {
    if (logoUrl == null) {
      // Display a placeholder if no logo URL is available
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Icon(Icons.business, color: Colors.grey),
      );
    } else {
      // Display the company logo
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          image: DecorationImage(
            image: NetworkImage(logoUrl),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) {
              // Handle image loading errors
              appLogger.d('Error loading company logo: $exception');
            },
          ),
        ),
      );
    }
  }

  Widget _buildFilterChip(String label, IconData icon) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        // Show filter dialog based on the label
        if (label == 'Location') {
          _showLocationFilterDialog();
        } else if (label == 'Type') {
          _showJobTypeFilterDialog();
        } else if (label == 'Category') {
          _showCategoryFilterDialog();
        } else if (label == 'Salary') {
          _showSalaryFilterDialog();
        }
      },
    );
  }

  /// Build active filter chips based on the current filters
  List<Widget> _buildActiveFilterChips(BuildContext context, Map<String, dynamic> filters) {
    final List<Widget> chips = [];

    // Add query filter chip
    if (filters.containsKey('query') && filters['query'] != null) {
      chips.add(
        Chip(
          label: Text('Search: ${filters['query']}'),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () {
            setState(() {
              _searchController.clear();
            });
            _applyCurrentFilters(excludeFilter: 'query');
          },
        ),
      );
    }

    // Add location filter chip
    if (filters.containsKey('location') && filters['location'] != null) {
      chips.add(
        Chip(
          label: Text('Location: ${filters['location']}'),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () {
            setState(() {
              _location = null;
            });
            _applyCurrentFilters(excludeFilter: 'location');
          },
        ),
      );
    }

    // Add job type filter chip
    if (filters.containsKey('job_type') && filters['job_type'] != null) {
      chips.add(
        Chip(
          label: Text('Type: ${filters['job_type']}'),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () {
            setState(() {
              _jobType = null;
            });
            _applyCurrentFilters(excludeFilter: 'job_type');
          },
        ),
      );
    }

    // Add category filter chip
    if (filters.containsKey('category') && filters['category'] != null) {
      chips.add(
        Chip(
          label: Text('Category: ${filters['category']}'),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () {
            setState(() {
              _category = null;
            });
            _applyCurrentFilters(excludeFilter: 'category');
          },
        ),
      );
    }

    // Add industry filter chip
    if (filters.containsKey('industry') && filters['industry'] != null) {
      chips.add(
        Chip(
          label: Text('Industry: ${filters['industry']}'),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () {
            setState(() {
              _industry = null;
            });
            _applyCurrentFilters(excludeFilter: 'industry');
          },
        ),
      );
    }

    // Add salary range filter chip
    if ((filters.containsKey('min_salary') && filters['min_salary'] != null) || 
        (filters.containsKey('max_salary') && filters['max_salary'] != null)) {
      final minSalary = filters['min_salary'];
      final maxSalary = filters['max_salary'];
      String salaryText = '';

      if (minSalary != null && maxSalary != null) {
        salaryText = '$minSalary - $maxSalary';
      } else if (minSalary != null) {
        salaryText = 'Min: $minSalary';
      } else if (maxSalary != null) {
        salaryText = 'Max: $maxSalary';
      }

      chips.add(
        Chip(
          label: Text('Salary: $salaryText'),
          deleteIcon: const Icon(Icons.close, size: 16),
          onDeleted: () {
            setState(() {
              _minSalary = null;
              _maxSalary = null;
            });
            _applyCurrentFilters(excludeFilter: 'salary');
          },
        ),
      );
    }

    // Add "Clear All" chip if there are any filters
    if (chips.isNotEmpty) {
      chips.add(
        ActionChip(
          label: const Text('Clear All'),
          avatar: const Icon(Icons.clear_all, size: 16),
          onPressed: () {
            setState(() {
              _searchController.clear();
              _location = null;
              _jobType = null;
              _category = null;
              _industry = null;
              _minSalary = null;
              _maxSalary = null;
            });
            context.read<JobsBloc>().add(ClearFiltersEvent());
          },
        ),
      );
    }

    return chips;
  }

  /// Apply current filters excluding the specified filter
  void _applyCurrentFilters({String? excludeFilter}) {
    context.read<JobsBloc>().add(ApplyFiltersEvent(
      query: excludeFilter == 'query' ? null : (_searchController.text.isNotEmpty ? _searchController.text : null),
      location: excludeFilter == 'location' ? null : _location,
      jobType: excludeFilter == 'job_type' ? null : _jobType,
      category: excludeFilter == 'category' ? null : _category,
      industry: excludeFilter == 'industry' ? null : _industry,
      minSalary: excludeFilter == 'salary' ? null : _minSalary,
      maxSalary: excludeFilter == 'salary' ? null : _maxSalary,
    ));
  }

  void _showLocationFilterDialog() {
    // TODO: Implement location filter dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Location'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter location',
          ),
          onChanged: (value) {
            setState(() {
              _location = value.isNotEmpty ? value : null;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Apply the location filter
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showJobTypeFilterDialog() {
    // TODO: Implement job type filter dialog
    final jobTypes = ['Full-Time', 'Part-Time', 'Contract', 'Internship', 'Freelance'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Job Type'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: jobTypes.length,
            itemBuilder: (context, index) {
              final type = jobTypes[index];
              return RadioListTile<String>(
                title: Text(type),
                value: type,
                groupValue: _jobType,
                onChanged: (value) {
                  setState(() {
                    _jobType = value;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCategoryFilterDialog() {
    // TODO: Implement category filter dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Category'),
        content: const Text('Category filters not yet implemented'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSalaryFilterDialog() {
    // TODO: Implement salary filter dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Salary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Minimum Salary',
                hintText: 'Enter minimum salary',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _minSalary = int.tryParse(value);
                  });
                } else {
                  setState(() {
                    _minSalary = null;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Maximum Salary',
                hintText: 'Enter maximum salary',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _maxSalary = int.tryParse(value);
                  });
                } else {
                  setState(() {
                    _maxSalary = null;
                  });
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Apply the salary filter
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildJobDetail(IconData icon, String text, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey.shade600),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(color: color ?? Colors.grey.shade600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Skeleton loading widget for job cards
  Widget _buildSkeletonJobCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        width: double.infinity,
        height: 210, // Increased height to prevent overflow
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade400, // Darker base color for more contrast
          highlightColor: Colors.grey.shade50, // Lighter highlight color for more contrast
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
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
                Container(
                  width: double.infinity,
                  height: 12,
                  color: Colors.white,
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

                // Button placeholder
                Container(
                  width: double.infinity,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
