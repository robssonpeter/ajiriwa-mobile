import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/application_repository.dart';
import 'applications_event.dart';
import 'applications_state.dart';

/// Applications bloc
class ApplicationsBloc extends Bloc<ApplicationsEvent, ApplicationsState> {
  /// Application repository
  final ApplicationRepository applicationRepository;

  /// Default number of applications per page
  static const int defaultPerPage = 10;

  /// Constructor
  ApplicationsBloc({required this.applicationRepository}) : super(ApplicationsInitial()) {
    on<LoadApplicationsEvent>(_onLoadApplications);
    on<LoadMoreApplicationsEvent>(_onLoadMoreApplications);
  }

  /// Handle load applications event
  Future<void> _onLoadApplications(
    LoadApplicationsEvent event,
    Emitter<ApplicationsState> emit,
  ) async {
    emit(const ApplicationsLoading());

    final result = await applicationRepository.getApplications(
      page: event.page ?? 1,
      perPage: event.perPage ?? defaultPerPage,
    );

    result.fold(
      (failure) => emit(ApplicationsError(failure.toString())),
      (applicationsResponse) => emit(ApplicationsLoaded.fromApplicationsResponse(applicationsResponse)),
    );
  }

  /// Handle load more applications event
  Future<void> _onLoadMoreApplications(
    LoadMoreApplicationsEvent event,
    Emitter<ApplicationsState> emit,
  ) async {
    // Only proceed if the current state is ApplicationsLoaded and hasMore is true
    if (state is ApplicationsLoaded) {
      final currentState = state as ApplicationsLoaded;

      if (!currentState.hasMore) {
        // No more applications to load
        return;
      }

      // Emit ApplicationsLoadingMore state to preserve the current applications list
      emit(ApplicationsLoadingMore(
        applications: currentState.applications,
        currentPage: currentState.currentPage,
        perPage: currentState.perPage,
        total: currentState.total,
        hasMore: currentState.hasMore,
        links: currentState.links,
      ));

      final result = await applicationRepository.getApplications(
        page: currentState.currentPage + 1,
        perPage: currentState.perPage,
      );

      result.fold(
        (failure) => emit(ApplicationsError(failure.toString())),
        (applicationsResponse) {
          // Combine the new applications with the existing ones
          final updatedApplications = [
            ...currentState.applications,
            ...applicationsResponse.applications,
          ];

          emit(ApplicationsLoaded(
            applications: updatedApplications,
            currentPage: applicationsResponse.currentPage,
            perPage: applicationsResponse.perPage,
            total: applicationsResponse.total,
            hasMore: applicationsResponse.nextPageUrl != null,
            links: applicationsResponse.links,
          ));
        },
      );
    }
  }
}