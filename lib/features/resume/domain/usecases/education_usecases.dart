import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/entities.dart';
import '../repositories/resume_repository.dart';

/// Add education use case
class AddEducation implements UseCase<bool, EducationParams> {
  /// Repository
  final ResumeRepository repository;

  /// Constructor
  const AddEducation(this.repository);

  @override
  Future<Either<Failure, bool>> call(EducationParams params) async {
    return await repository.addEducation(params.education, candidateId: params.candidateId);
  }
}

/// Update education use case
class UpdateEducation implements UseCase<bool, EducationParams> {
  /// Repository
  final ResumeRepository repository;

  /// Constructor
  const UpdateEducation(this.repository);

  @override
  Future<Either<Failure, bool>> call(EducationParams params) async {
    return await repository.updateEducation(params.education, candidateId: params.candidateId);
  }
}

/// Delete education use case
class DeleteEducation implements UseCase<bool, DeleteEducationParams> {
  /// Repository
  final ResumeRepository repository;

  /// Constructor
  const DeleteEducation(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteEducationParams params) async {
    return await repository.deleteEducation(params.educationId, candidateId: params.candidateId);
  }
}

/// Parameters for education use cases
class EducationParams extends Equatable {
  /// Education information
  final Education education;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const EducationParams({
    required this.education,
    this.candidateId,
  });

  @override
  List<Object?> get props => [education, candidateId];
}

/// Parameters for delete education use case
class DeleteEducationParams extends Equatable {
  /// Education ID
  final int educationId;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const DeleteEducationParams({
    required this.educationId,
    this.candidateId,
  });

  @override
  List<Object?> get props => [educationId, candidateId];
}