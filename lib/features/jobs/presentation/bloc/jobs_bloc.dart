import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/job_repository.dart';
import '../../domain/entities/job_listing.dart';
import 'jobs_event.dart';
import 'jobs_state.dart';

/// Jobs bloc
class JobsBloc extends Bloc<JobsEvent, JobsState> {
  /// Job repository
  final JobRepository jobRepository;

  /// Default number of jobs per page
  static const int defaultPerPage = 10;

  /// Constructor
  JobsBloc({required this.jobRepository}) : super(JobsInitial()) {
    on<LoadJobsEvent>(_onLoadJobs);
    on<LoadMoreJobsEvent>(_onLoadMoreJobs);
    on<ApplyFiltersEvent>(_onApplyFilters);
    on<ClearFiltersEvent>(_onClearFilters);
    on<ToggleJobSavedEvent>(_onToggleJobSaved);
  }

  /// Handle load jobs event
  Future<void> _onLoadJobs(
    LoadJobsEvent event,
    Emitter<JobsState> emit,
  ) async {
    emit(const JobsLoading());

    // Build filters map
    final filters = <String, dynamic>{};
    if (event.query != null && event.query!.isNotEmpty) {
      filters['query'] = event.query;
    }
    if (event.location != null && event.location!.isNotEmpty) {
      filters['location'] = event.location;
    }
    if (event.jobType != null && event.jobType!.isNotEmpty) {
      filters['job_type'] = event.jobType;
    }
    if (event.category != null) {
      filters['category'] = event.category;
    }
    if (event.industry != null) {
      filters['industry'] = event.industry;
    }
    if (event.minSalary != null) {
      filters['min_salary'] = event.minSalary;
    }
    if (event.maxSalary != null) {
      filters['max_salary'] = event.maxSalary;
    }

    final result = await jobRepository.getJobs(
      query: event.query,
      location: event.location,
      jobType: event.jobType,
      category: event.category,
      industry: event.industry,
      minSalary: event.minSalary,
      maxSalary: event.maxSalary,
      page: 1,
      perPage: defaultPerPage,
    );

    result.fold(
      (failure) => emit(JobsError(failure.toString())),
      (jobsResponse) => emit(JobsLoaded.fromJobsResponse(jobsResponse, filters: filters)),
    );
  }

  /// Handle load more jobs event
  Future<void> _onLoadMoreJobs(
    LoadMoreJobsEvent event,
    Emitter<JobsState> emit,
  ) async {
    // Only proceed if the current state is JobsLoaded and hasMore is true
    if (state is JobsLoaded) {
      final currentState = state as JobsLoaded;

      if (!currentState.hasMore) {
        // No more jobs to load
        return;
      }

      // Emit JobsLoadingMore state to preserve the current jobs list
      emit(JobsLoadingMore(
        jobs: currentState.jobs,
        sponsoredJobs: currentState.sponsoredJobs,
        page: currentState.page,
        perPage: currentState.perPage,
        total: currentState.total,
        hasMore: currentState.hasMore,
        filters: currentState.filters,
      ));

      // Extract filters from current state
      final filters = currentState.filters;

      final result = await jobRepository.getJobs(
        query: filters['query'] as String?,
        location: filters['location'] as String?,
        jobType: filters['job_type'] as String?,
        category: filters['category'] as int?,
        industry: filters['industry'] as int?,
        minSalary: filters['min_salary'] as int?,
        maxSalary: filters['max_salary'] as int?,
        page: currentState.page + 1,
        perPage: currentState.perPage,
      );

      result.fold(
        (failure) => emit(JobsError(failure.toString())),
        (jobsResponse) {
          // Combine the new jobs with the existing ones
          final updatedJobs = [...currentState.jobs, ...jobsResponse.jobs];

          emit(JobsLoaded(
            jobs: updatedJobs,
            sponsoredJobs: currentState.sponsoredJobs, // Keep the same sponsored jobs
            page: jobsResponse.page,
            perPage: jobsResponse.perPage,
            total: jobsResponse.total,
            hasMore: jobsResponse.hasMore,
            filters: filters,
          ));
        },
      );
    }
  }

  /// Handle apply filters event
  Future<void> _onApplyFilters(
    ApplyFiltersEvent event,
    Emitter<JobsState> emit,
  ) async {
    emit(const JobsLoading());

    // Build filters map
    final filters = <String, dynamic>{};
    if (event.query != null && event.query!.isNotEmpty) {
      filters['query'] = event.query;
    }
    if (event.location != null && event.location!.isNotEmpty) {
      filters['location'] = event.location;
    }
    if (event.jobType != null && event.jobType!.isNotEmpty) {
      filters['job_type'] = event.jobType;
    }
    if (event.category != null) {
      filters['category'] = event.category;
    }
    if (event.industry != null) {
      filters['industry'] = event.industry;
    }
    if (event.minSalary != null) {
      filters['min_salary'] = event.minSalary;
    }
    if (event.maxSalary != null) {
      filters['max_salary'] = event.maxSalary;
    }

    final result = await jobRepository.getJobs(
      query: event.query,
      location: event.location,
      jobType: event.jobType,
      category: event.category,
      industry: event.industry,
      minSalary: event.minSalary,
      maxSalary: event.maxSalary,
      page: 1, // Reset to first page when applying filters
      perPage: defaultPerPage,
    );

    result.fold(
      (failure) => emit(JobsError(failure.toString())),
      (jobsResponse) => emit(JobsLoaded.fromJobsResponse(jobsResponse, filters: filters)),
    );
  }

  /// Handle clear filters event
  Future<void> _onClearFilters(
    ClearFiltersEvent event,
    Emitter<JobsState> emit,
  ) async {
    emit(const JobsLoading());

    final result = await jobRepository.getJobs(
      page: 1,
      perPage: defaultPerPage,
    );

    result.fold(
      (failure) => emit(JobsError(failure.toString())),
      (jobsResponse) => emit(JobsLoaded.fromJobsResponse(jobsResponse)),
    );
  }

  /// Handle toggle job saved event
  Future<void> _onToggleJobSaved(
    ToggleJobSavedEvent event,
    Emitter<JobsState> emit,
  ) async {
    // Store the current state to restore it later if needed
    final currentState = state;
    if (currentState is! JobsLoaded) {
      // Can only toggle saved status if jobs are loaded
      return;
    }

    // Emit saving/unsaving state
    if (event.isSaved) {
      emit(JobUnsavingState(
        jobId: event.jobId,
        jobs: currentState.jobs,
        sponsoredJobs: currentState.sponsoredJobs,
        page: currentState.page,
        perPage: currentState.perPage,
        total: currentState.total,
        hasMore: currentState.hasMore,
        filters: currentState.filters,
      ));
    } else {
      emit(JobSavingState(
        jobId: event.jobId,
        jobs: currentState.jobs,
        sponsoredJobs: currentState.sponsoredJobs,
        page: currentState.page,
        perPage: currentState.perPage,
        total: currentState.total,
        hasMore: currentState.hasMore,
        filters: currentState.filters,
      ));
    }

    // Call the appropriate repository method
    final result = event.isSaved
        ? await jobRepository.unsaveJob(event.jobId)
        : await jobRepository.saveJob(event.jobId);

    result.fold(
      (failure) {
        // Emit error state
        emit(JobSaveErrorState(
          message: failure.toString(),
          jobId: event.jobId,
          wasSaving: !event.isSaved,
        ));

        // Restore previous state
        emit(currentState);
      },
      (_) {
        // Update the job list with the new saved status
        final updatedJobs = currentState.jobs.map((job) {
          if (job.id == event.jobId) {
            // Create a new job with the updated isSaved status
            return JobListing(
              id: job.id,
              slug: job.slug,
              title: job.title,
              companyName: job.companyName,
              location: job.location,
              jobType: job.jobType,
              postedTimeago: job.postedTimeago,
              companyLogoUrl: job.companyLogoUrl,
              isApplied: job.isApplied,
              isSaved: !event.isSaved, // Toggle the saved status
            );
          }
          return job;
        }).toList();

        // Update sponsored jobs as well if needed
        final updatedSponsoredJobs = currentState.sponsoredJobs.map((job) {
          if (job.id == event.jobId) {
            return JobListing(
              id: job.id,
              slug: job.slug,
              title: job.title,
              companyName: job.companyName,
              location: job.location,
              jobType: job.jobType,
              postedTimeago: job.postedTimeago,
              companyLogoUrl: job.companyLogoUrl,
              isApplied: job.isApplied,
              isSaved: !event.isSaved, // Toggle the saved status
            );
          }
          return job;
        }).toList();

        // Find the job that was toggled to get its title
        String jobTitle = '';
        for (final job in currentState.jobs) {
          if (job.id == event.jobId) {
            jobTitle = job.title;
            break;
          }
        }
        if (jobTitle.isEmpty) {
          for (final job in currentState.sponsoredJobs) {
            if (job.id == event.jobId) {
              jobTitle = job.title;
              break;
            }
          }
        }

        // Emit success state
        if (event.isSaved) {
          emit(JobUnsavedSuccessState(jobId: event.jobId, jobTitle: jobTitle));
        } else {
          emit(JobSavedSuccessState(jobId: event.jobId, jobTitle: jobTitle));
        }

        // Emit updated state
        emit(JobsLoaded(
          jobs: updatedJobs,
          sponsoredJobs: updatedSponsoredJobs,
          page: currentState.page,
          perPage: currentState.perPage,
          total: currentState.total,
          hasMore: currentState.hasMore,
          filters: currentState.filters,
        ));
      },
    );
  }
}
