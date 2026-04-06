import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/application_repository.dart';
import 'application_details_event.dart';
import 'application_details_state.dart';

/// Bloc for managing application details state
class ApplicationDetailsBloc extends Bloc<ApplicationDetailsEvent, ApplicationDetailsState> {
  /// Application repository
  final ApplicationRepository applicationRepository;

  /// Constructor
  ApplicationDetailsBloc({
    required this.applicationRepository,
  }) : super(ApplicationDetailsInitial()) {
    on<LoadApplicationDetailsEvent>(_onLoadApplicationDetails);
  }

  /// Handle load application details event
  Future<void> _onLoadApplicationDetails(
    LoadApplicationDetailsEvent event,
    Emitter<ApplicationDetailsState> emit,
  ) async {
    emit(ApplicationDetailsLoading());

    final result = await applicationRepository.getApplicationDetails(event.applicationId);

    result.fold(
      (failure) => emit(ApplicationDetailsError(failure.message)),
      (applicationDetails) => emit(ApplicationDetailsLoaded(applicationDetails)),
    );
  }
}