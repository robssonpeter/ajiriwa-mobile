import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/cv_optimization_repository.dart';
import 'cv_optimization_event.dart';
import 'cv_optimization_state.dart';

class CvOptimizationBloc extends Bloc<CvOptimizationEvent, CvOptimizationState> {
  final CvOptimizationRepository repository;

  CvOptimizationBloc({required this.repository}) : super(CvOptimizationInitial()) {
    on<LoadOptimizations>(_onLoadOptimizations);
    on<LoadOptimizationsForJob>(_onLoadOptimizationsForJob);
    on<CreateOptimization>(_onCreateOptimization);
    on<GeneratePdf>(_onGeneratePdf);
    on<PollPdfStatus>(_onPollPdfStatus);
    on<DeleteOptimization>(_onDeleteOptimization);
    on<LoadSubscriptionPlans>(_onLoadSubscriptionPlans);
    on<InitiatePayment>(_onInitiatePayment);
    on<CheckPaymentStatus>(_onCheckPaymentStatus);
  }

  Future<void> _onLoadOptimizations(
      LoadOptimizations event, Emitter<CvOptimizationState> emit) async {
    emit(CvOptimizationLoading());
    try {
      final optimizations = await repository.getOptimizations();
      emit(CvOptimizationsLoaded(optimizations));
    } catch (e) {
      emit(CvOptimizationError(e.toString()));
    }
  }

  Future<void> _onLoadOptimizationsForJob(
      LoadOptimizationsForJob event, Emitter<CvOptimizationState> emit) async {
    emit(CvOptimizationLoading());
    try {
      final optimizations = await repository.getOptimizationsForJob(event.jobId);
      emit(CvOptimizationsLoaded(optimizations));
    } catch (e) {
      emit(CvOptimizationError(e.toString()));
    }
  }

  Future<void> _onCreateOptimization(
      CreateOptimization event, Emitter<CvOptimizationState> emit) async {
    final current = state is CvOptimizationsLoaded
        ? (state as CvOptimizationsLoaded).optimizations
        : <dynamic>[];
    emit(CvOptimizationActionLoading(optimizations: List.from(current)));
    try {
      final optimization = await repository.createOptimization(
        jobId: event.jobId,
        candidateId: event.candidateId,
        refinementInstruction: event.refinementInstruction,
      );
      emit(CvOptimizationCreated(optimization));
    } catch (e) {
      emit(CvOptimizationError(e.toString(), optimizations: List.from(current)));
    }
  }

  Future<void> _onGeneratePdf(
      GeneratePdf event, Emitter<CvOptimizationState> emit) async {
    try {
      final optimization = await repository.generatePdf(event.optimizationId);
      emit(CvOptimizationPdfGenerating(optimization));
    } catch (e) {
      emit(CvOptimizationError(e.toString()));
    }
  }

  Future<void> _onPollPdfStatus(
      PollPdfStatus event, Emitter<CvOptimizationState> emit) async {
    try {
      final status = await repository.getPdfStatus(event.optimizationId);
      if (status == 'completed') {
        final optimization = await repository.getOptimization(event.optimizationId);
        emit(CvOptimizationPdfReady(optimization));
      }
    } catch (e) {
      emit(CvOptimizationError(e.toString()));
    }
  }

  Future<void> _onDeleteOptimization(
      DeleteOptimization event, Emitter<CvOptimizationState> emit) async {
    try {
      await repository.deleteOptimization(event.optimizationId);
      emit(CvOptimizationDeleted());
    } catch (e) {
      emit(CvOptimizationError(e.toString()));
    }
  }

  Future<void> _onLoadSubscriptionPlans(
      LoadSubscriptionPlans event, Emitter<CvOptimizationState> emit) async {
    emit(SubscriptionPlansLoading());
    try {
      final plans = await repository.getSubscriptionPlans();
      emit(SubscriptionPlansLoaded(plans));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onInitiatePayment(
      InitiatePayment event, Emitter<CvOptimizationState> emit) async {
    emit(PaymentInitiating());
    try {
      final result = await repository.initiatePayment(
        planId: event.planId,
        fromUrl: 'https://www.ajiriwa.net/subscription/select',
      );
      final url = result['redirect_url'] as String? ??
          result['payment_url'] as String? ??
          result['url'] as String? ??
          '';
      final trackingId = result['order_tracking_id'] as String? ??
          result['tracking_id'] as String? ??
          '';
      emit(PaymentInitiated(paymentUrl: url, trackingId: trackingId));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onCheckPaymentStatus(
      CheckPaymentStatus event, Emitter<CvOptimizationState> emit) async {
    try {
      final result = await repository.checkPaymentStatus(event.trackingId);
      final statusDesc = result['payment_status_description'] as String? ?? 'PENDING';
      emit(PaymentStatusChecked(
        status: statusDesc,
        isCompleted: statusDesc == 'Completed',
      ));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }
}
