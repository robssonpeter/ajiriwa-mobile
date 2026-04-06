import 'package:equatable/equatable.dart';

abstract class CvOptimizationEvent extends Equatable {
  const CvOptimizationEvent();
  @override
  List<Object?> get props => [];
}

class LoadOptimizations extends CvOptimizationEvent {
  const LoadOptimizations();
}

class LoadOptimizationsForJob extends CvOptimizationEvent {
  final int jobId;
  const LoadOptimizationsForJob(this.jobId);
  @override
  List<Object?> get props => [jobId];
}

class CreateOptimization extends CvOptimizationEvent {
  final int jobId;
  final int candidateId;
  final String? refinementInstruction;
  const CreateOptimization({
    required this.jobId,
    required this.candidateId,
    this.refinementInstruction,
  });
  @override
  List<Object?> get props => [jobId, candidateId, refinementInstruction];
}

class GeneratePdf extends CvOptimizationEvent {
  final int optimizationId;
  const GeneratePdf(this.optimizationId);
  @override
  List<Object?> get props => [optimizationId];
}

class PollPdfStatus extends CvOptimizationEvent {
  final int optimizationId;
  const PollPdfStatus(this.optimizationId);
  @override
  List<Object?> get props => [optimizationId];
}

class DeleteOptimization extends CvOptimizationEvent {
  final int optimizationId;
  const DeleteOptimization(this.optimizationId);
  @override
  List<Object?> get props => [optimizationId];
}

class LoadSubscriptionPlans extends CvOptimizationEvent {
  const LoadSubscriptionPlans();
}

class InitiatePayment extends CvOptimizationEvent {
  final int planId;
  const InitiatePayment(this.planId);
  @override
  List<Object?> get props => [planId];
}

class CheckPaymentStatus extends CvOptimizationEvent {
  final String trackingId;
  const CheckPaymentStatus(this.trackingId);
  @override
  List<Object?> get props => [trackingId];
}
