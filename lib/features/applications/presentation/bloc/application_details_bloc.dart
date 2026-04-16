import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/application_details.dart';
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
    on<WithdrawApplicationEvent>(_onWithdrawApplication);
    on<GenerateInterviewPrepEvent>(_onGenerateInterviewPrep);
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

  /// Handle withdraw application event
  Future<void> _onWithdrawApplication(
    WithdrawApplicationEvent event,
    Emitter<ApplicationDetailsState> emit,
  ) async {
    emit(const ApplicationWithdrawing());

    final result = await applicationRepository.withdrawApplication(event.applicationId);

    result.fold(
      (failure) => emit(ApplicationDetailsError(failure.message)),
      (_) => emit(const ApplicationWithdrawn()),
    );
  }

  /// Handle generate interview prep event
  Future<void> _onGenerateInterviewPrep(
    GenerateInterviewPrepEvent event,
    Emitter<ApplicationDetailsState> emit,
  ) async {
    final current = state;
    ApplicationDetails? details;
    if (current is ApplicationDetailsLoaded) details = current.applicationDetails;
    if (current is InterviewPrepLoaded) details = current.applicationDetails;
    if (current is InterviewPrepError) details = current.applicationDetails;
    if (details == null) return;

    emit(InterviewPrepLoading(details));

    final result = await applicationRepository.generateInterviewPrep(
      event.scheduleId,
      refresh: event.refresh,
    );

    result.fold(
      (failure) => emit(InterviewPrepError(applicationDetails: details!, message: failure.message)),
      (prepData) => emit(InterviewPrepLoaded(applicationDetails: details!, prepData: prepData)),
    );
  }
}
