import 'package:equatable/equatable.dart';
import '../../domain/entities/cv_optimization.dart';
import '../../domain/entities/subscription_plan.dart';

abstract class CvOptimizationState extends Equatable {
  const CvOptimizationState();
  @override
  List<Object?> get props => [];
}

class CvOptimizationInitial extends CvOptimizationState {}

class CvOptimizationLoading extends CvOptimizationState {}

class CvOptimizationActionLoading extends CvOptimizationState {
  final List<CvOptimization> optimizations;
  const CvOptimizationActionLoading({required this.optimizations});
  @override
  List<Object?> get props => [optimizations];
}

class CvOptimizationsLoaded extends CvOptimizationState {
  final List<CvOptimization> optimizations;
  const CvOptimizationsLoaded(this.optimizations);
  @override
  List<Object?> get props => [optimizations];
}

class CvOptimizationCreated extends CvOptimizationState {
  final CvOptimization optimization;
  const CvOptimizationCreated(this.optimization);
  @override
  List<Object?> get props => [optimization];
}

class CvOptimizationPdfGenerating extends CvOptimizationState {
  final CvOptimization optimization;
  const CvOptimizationPdfGenerating(this.optimization);
  @override
  List<Object?> get props => [optimization];
}

class CvOptimizationPdfReady extends CvOptimizationState {
  final CvOptimization optimization;
  const CvOptimizationPdfReady(this.optimization);
  @override
  List<Object?> get props => [optimization];
}

class CvOptimizationDeleted extends CvOptimizationState {}

class CvOptimizationError extends CvOptimizationState {
  final String message;
  final List<CvOptimization> optimizations;
  const CvOptimizationError(this.message, {this.optimizations = const []});
  @override
  List<Object?> get props => [message, optimizations];
}

// Subscription & Payment states
class SubscriptionPlansLoading extends CvOptimizationState {}

class SubscriptionPlansLoaded extends CvOptimizationState {
  final List<SubscriptionPlan> plans;
  const SubscriptionPlansLoaded(this.plans);
  @override
  List<Object?> get props => [plans];
}

class PaymentInitiating extends CvOptimizationState {}

class PaymentInitiated extends CvOptimizationState {
  final String paymentUrl;
  final String trackingId;
  const PaymentInitiated({required this.paymentUrl, required this.trackingId});
  @override
  List<Object?> get props => [paymentUrl, trackingId];
}

class PaymentStatusChecked extends CvOptimizationState {
  final String status;
  final bool isCompleted;
  const PaymentStatusChecked({required this.status, required this.isCompleted});
  @override
  List<Object?> get props => [status, isCompleted];
}

class PaymentError extends CvOptimizationState {
  final String message;
  const PaymentError(this.message);
  @override
  List<Object?> get props => [message];
}
