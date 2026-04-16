import 'package:equatable/equatable.dart';

abstract class JobAlertsEvent extends Equatable {
  const JobAlertsEvent();
  @override
  List<Object?> get props => [];
}

class LoadJobAlertsEvent extends JobAlertsEvent {}

class CreateJobAlertEvent extends JobAlertsEvent {
  final String name;
  final String? keywords;
  final String? location;
  final int? jobTypeId;
  final bool isRemote;

  const CreateJobAlertEvent({
    required this.name,
    this.keywords,
    this.location,
    this.jobTypeId,
    this.isRemote = false,
  });

  @override
  List<Object?> get props => [name, keywords, location, jobTypeId, isRemote];
}

class UpdateJobAlertEvent extends JobAlertsEvent {
  final int id;
  final String name;
  final String? keywords;
  final String? location;
  final int? jobTypeId;
  final bool isRemote;
  final bool isActive;

  const UpdateJobAlertEvent({
    required this.id,
    required this.name,
    this.keywords,
    this.location,
    this.jobTypeId,
    this.isRemote = false,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, name, keywords, location, jobTypeId, isRemote, isActive];
}

class DeleteJobAlertEvent extends JobAlertsEvent {
  final int id;
  const DeleteJobAlertEvent(this.id);
  @override
  List<Object?> get props => [id];
}
