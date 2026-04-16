import 'package:equatable/equatable.dart';

class JobAlert extends Equatable {
  final int id;
  final String name;
  final String? keywords;
  final String? location;
  final int? jobTypeId;
  final String? jobTypeName;
  final bool isRemote;
  final bool isActive;
  final String? lastNotifiedAt;
  final String createdAt;

  const JobAlert({
    required this.id,
    required this.name,
    this.keywords,
    this.location,
    this.jobTypeId,
    this.jobTypeName,
    required this.isRemote,
    required this.isActive,
    this.lastNotifiedAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id, name, keywords, location, jobTypeId, jobTypeName,
        isRemote, isActive, lastNotifiedAt, createdAt,
      ];
}
