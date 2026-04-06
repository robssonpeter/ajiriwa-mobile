import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/entities.dart';
import '../repositories/resume_repository.dart';

/// Add skill use case
class AddSkill implements UseCase<bool, SkillParams> {
  /// Repository
  final ResumeRepository repository;

  /// Constructor
  const AddSkill(this.repository);

  @override
  Future<Either<Failure, bool>> call(SkillParams params) async {
    return await repository.addSkill(params.skill, candidateId: params.candidateId);
  }
}

/// Update skill use case
class UpdateSkill implements UseCase<bool, SkillParams> {
  /// Repository
  final ResumeRepository repository;

  /// Constructor
  const UpdateSkill(this.repository);

  @override
  Future<Either<Failure, bool>> call(SkillParams params) async {
    return await repository.updateSkill(params.skill, candidateId: params.candidateId);
  }
}

/// Delete skill use case
class DeleteSkill implements UseCase<bool, DeleteSkillParams> {
  /// Repository
  final ResumeRepository repository;

  /// Constructor
  const DeleteSkill(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteSkillParams params) async {
    return await repository.deleteSkill(params.skillId, candidateId: params.candidateId);
  }
}

/// Parameters for skill use cases
class SkillParams extends Equatable {
  /// Skill information
  final Skill skill;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const SkillParams({
    required this.skill,
    this.candidateId,
  });

  @override
  List<Object?> get props => [skill, candidateId];
}

/// Parameters for delete skill use case
class DeleteSkillParams extends Equatable {
  /// Skill ID
  final int skillId;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const DeleteSkillParams({
    required this.skillId,
    this.candidateId,
  });

  @override
  List<Object?> get props => [skillId, candidateId];
}