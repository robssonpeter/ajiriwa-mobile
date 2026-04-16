import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/job_alert.dart';
import '../../domain/repositories/job_alert_repository.dart';
import 'job_alerts_event.dart';
import 'job_alerts_state.dart';

class JobAlertsBloc extends Bloc<JobAlertsEvent, JobAlertsState> {
  final JobAlertRepository repository;

  JobAlertsBloc({required this.repository}) : super(JobAlertsInitial()) {
    on<LoadJobAlertsEvent>(_onLoad);
    on<CreateJobAlertEvent>(_onCreate);
    on<UpdateJobAlertEvent>(_onUpdate);
    on<DeleteJobAlertEvent>(_onDelete);
  }

  List<JobAlert> _currentAlerts() {
    final s = state;
    if (s is JobAlertsLoaded) return List.from(s.alerts);
    if (s is JobAlertsSaving) return List.from(s.alerts);
    if (s is JobAlertSaved) return List.from(s.alerts);
    return [];
  }

  Future<void> _onLoad(LoadJobAlertsEvent event, Emitter<JobAlertsState> emit) async {
    emit(JobAlertsLoading());
    final result = await repository.getAlerts();
    result.fold(
      (failure) => emit(JobAlertsError(failure.message)),
      (alerts) => emit(JobAlertsLoaded(alerts)),
    );
  }

  Future<void> _onCreate(CreateJobAlertEvent event, Emitter<JobAlertsState> emit) async {
    final current = _currentAlerts();
    emit(JobAlertsSaving(current));
    final result = await repository.createAlert(
      name: event.name,
      keywords: event.keywords,
      location: event.location,
      jobTypeId: event.jobTypeId,
      isRemote: event.isRemote,
    );
    result.fold(
      (failure) => emit(JobAlertsError(failure.message)),
      (alert) {
        final updated = [alert, ...current];
        emit(JobAlertSaved(alerts: updated, message: 'Job alert created successfully'));
      },
    );
  }

  Future<void> _onUpdate(UpdateJobAlertEvent event, Emitter<JobAlertsState> emit) async {
    final current = _currentAlerts();
    emit(JobAlertsSaving(current));
    final result = await repository.updateAlert(
      id: event.id,
      name: event.name,
      keywords: event.keywords,
      location: event.location,
      jobTypeId: event.jobTypeId,
      isRemote: event.isRemote,
      isActive: event.isActive,
    );
    result.fold(
      (failure) => emit(JobAlertsError(failure.message)),
      (updated) {
        final updatedList = current.map((a) => a.id == event.id ? updated : a).toList();
        emit(JobAlertSaved(alerts: updatedList, message: 'Job alert updated'));
      },
    );
  }

  Future<void> _onDelete(DeleteJobAlertEvent event, Emitter<JobAlertsState> emit) async {
    final current = _currentAlerts();
    // Optimistic removal
    final optimistic = current.where((a) => a.id != event.id).toList();
    emit(JobAlertsSaving(optimistic));
    final result = await repository.deleteAlert(event.id);
    result.fold(
      (failure) => emit(JobAlertsLoaded(current)), // revert on error
      (_) => emit(JobAlertSaved(alerts: optimistic, message: 'Alert deleted')),
    );
  }
}
