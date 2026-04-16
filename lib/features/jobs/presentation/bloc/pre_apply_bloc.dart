import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/job_repository.dart';
import 'pre_apply_event.dart';
import 'pre_apply_state.dart';

class PreApplyBloc extends Bloc<PreApplyEvent, PreApplyState> {
  final JobRepository jobRepository;

  PreApplyBloc({required this.jobRepository}) : super(PreApplyInitial()) {
    on<LoadExistingAnalysisEvent>(_onLoadExisting);
    on<RunAnalysisEvent>(_onRunAnalysis);
  }

  Future<void> _onLoadExisting(
    LoadExistingAnalysisEvent event,
    Emitter<PreApplyState> emit,
  ) async {
    emit(PreApplyLoading());
    final result = await jobRepository.getAnalysis(event.jobSlug);
    result.fold(
      (failure) => emit(PreApplyNoExisting()),
      (analysis) {
        if (analysis == null) {
          emit(PreApplyNoExisting());
        } else {
          emit(PreApplyLoaded(analysis));
        }
      },
    );
  }

  Future<void> _onRunAnalysis(
    RunAnalysisEvent event,
    Emitter<PreApplyState> emit,
  ) async {
    emit(PreApplyAnalyzing());
    final result = await jobRepository.analyzeApplication(
      jobSlug: event.jobSlug,
      coverLetter: event.coverLetter,
      screeningResponses: event.screeningResponses,
      cvOptimizationId: event.cvOptimizationId,
    );
    result.fold(
      (failure) {
        final isSubRequired = failure.message.toLowerCase().contains('subscription');
        emit(PreApplyError(failure.message, isSubscriptionRequired: isSubRequired));
      },
      (analysis) => emit(PreApplyLoaded(analysis)),
    );
  }
}
