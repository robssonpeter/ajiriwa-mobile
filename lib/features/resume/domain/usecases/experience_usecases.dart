import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/entities.dart';
import '../repositories/resume_repository.dart';

/// Add experience use case
class AddExperience implements UseCase<bool, ExperienceParams> {
  /// Repository
  final ResumeRepository repository;

  /// Constructor
  const AddExperience(this.repository);

  @override
  Future<Either<Failure, bool>> call(ExperienceParams params) async {
    return await repository.addExperience(params.experience, candidateId: params.candidateId);
  }
}

/// Update experience use case
class UpdateExperience implements UseCase<bool, ExperienceParams> {
  /// Repository
  final ResumeRepository repository;

  /// Constructor
  const UpdateExperience(this.repository);

  @override
  Future<Either<Failure, bool>> call(ExperienceParams params) async {
    return await repository.updateExperience(params.experience, candidateId: params.candidateId);
  }
}

/// Delete experience use case
class DeleteExperience implements UseCase<bool, DeleteExperienceParams> {
  /// Repository
  final ResumeRepository repository;

  /// Constructor
  const DeleteExperience(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteExperienceParams params) async {
    return await repository.deleteExperience(params.experienceId, candidateId: params.candidateId);
  }
}

/// Parameters for experience use cases
class ExperienceParams extends Equatable {
  /// Experience information
  final Experience experience;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const ExperienceParams({
    required this.experience,
    this.candidateId,
  });

  @override
  List<Object?> get props => [experience, candidateId];
}

/// Parameters for delete experience use case
class DeleteExperienceParams extends Equatable {
  /// Experience ID
  final int experienceId;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const DeleteExperienceParams({
    required this.experienceId,
    this.candidateId,
  });

  @override
  List<Object?> get props => [experienceId, candidateId];
}