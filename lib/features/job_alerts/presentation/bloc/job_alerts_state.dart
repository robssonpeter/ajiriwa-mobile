import 'package:equatable/equatable.dart';

import '../../domain/entities/job_alert.dart';

abstract class JobAlertsState extends Equatable {
  const JobAlertsState();
  @override
  List<Object?> get props => [];
}

class JobAlertsInitial extends JobAlertsState {}

class JobAlertsLoading extends JobAlertsState {}

class JobAlertsLoaded extends JobAlertsState {
  final List<JobAlert> alerts;
  const JobAlertsLoaded(this.alerts);
  @override
  List<Object?> get props => [alerts];
}

class JobAlertsSaving extends JobAlertsState {
  final List<JobAlert> alerts;
  const JobAlertsSaving(this.alerts);
  @override
  List<Object?> get props => [alerts];
}

class JobAlertSaved extends JobAlertsState {
  final List<JobAlert> alerts;
  final String message;
  const JobAlertSaved({required this.alerts, required this.message});
  @override
  List<Object?> get props => [alerts, message];
}

class JobAlertsError extends JobAlertsState {
  final String message;
  const JobAlertsError(this.message);
  @override
  List<Object?> get props => [message];
}
