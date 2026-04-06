import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

/// Dashboard bloc
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  /// Dashboard repository
  final DashboardRepository dashboardRepository;

  /// Constructor
  DashboardBloc({required this.dashboardRepository}) : super(DashboardInitial()) {
    on<LoadDashboardEvent>(_onLoadDashboard);
  }

  /// Handle load dashboard event
  Future<void> _onLoadDashboard(
    LoadDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    try {
      // Add timeout to prevent indefinite loading
      final result = await dashboardRepository.getDashboard().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timed out. Please check your internet connection and try again.');
        },
      );

      result.fold(
        (failure) {
          // Provide more user-friendly error messages
          String errorMessage;
          if (failure.toString().contains('NetworkFailure')) {
            errorMessage = 'No internet connection. Please check your network and try again.';
          } else if (failure.toString().contains('ServerFailure')) {
            errorMessage = 'Server error occurred. Please try again later.';
          } else {
            errorMessage = 'Something went wrong. Please try again.';
          }
          emit(DashboardError(errorMessage));
        },
        (dashboard) => emit(DashboardLoaded(dashboard)),
      );
    } catch (e) {
      // Handle timeout and other unexpected errors
      String errorMessage;
      if (e.toString().contains('timed out')) {
        errorMessage = 'Request timed out. Please check your internet connection and try again.';
      } else {
        errorMessage = 'An unexpected error occurred. Please try again.';
      }
      emit(DashboardError(errorMessage));
    }
  }
}
