import 'package:equatable/equatable.dart';

import '../../domain/entities/pre_apply_analysis.dart';

abstract class PreApplyState extends Equatable {
  const PreApplyState();
  @override
  List<Object?> get props => [];
}

class PreApplyInitial extends PreApplyState {}

class PreApplyLoading extends PreApplyState {}

class PreApplyAnalyzing extends PreApplyState {}

class PreApplyLoaded extends PreApplyState {
  final PreApplyAnalysis analysis;
  const PreApplyLoaded(this.analysis);
  @override
  List<Object?> get props => [analysis];
}

class PreApplyNoExisting extends PreApplyState {}

class PreApplyError extends PreApplyState {
  final String message;
  final bool isSubscriptionRequired;
  const PreApplyError(this.message, {this.isSubscriptionRequired = false});
  @override
  List<Object?> get props => [message, isSubscriptionRequired];
}
