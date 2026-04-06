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
    final result = await dashboardRepository.getDashboard();
    result.fold(
      (failure) => emit(DashboardError(failure.toString())),
      (dashboard) => emit(DashboardLoaded(dashboard)),
    );
  }
}
