import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/entities.dart';
import '../repositories/resume_repository.dart';

/// Add reference use case
class AddReference implements UseCase<bool, ReferenceParams> {
  /// Repository
  final ResumeRepository repository;

  /// Constructor
  const AddReference(this.repository);

  @override
  Future<Either<Failure, bool>> call(ReferenceParams params) async {
    return await repository.addReference(params.reference, candidateId: params.candidateId);
  }
}

/// Update reference use case
class UpdateReference implements UseCase<bool, ReferenceParams> {
  /// Repository
  final ResumeRepository repository;

  /// Constructor
  const UpdateReference(this.repository);

  @override
  Future<Either<Failure, bool>> call(ReferenceParams params) async {
    return await repository.updateReference(params.reference, candidateId: params.candidateId);
  }
}

/// Delete reference use case
class DeleteReference implements UseCase<bool, DeleteReferenceParams> {
  /// Repository
  final ResumeRepository repository;

  /// Constructor
  const DeleteReference(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteReferenceParams params) async {
    return await repository.deleteReference(params.referenceId, candidateId: params.candidateId);
  }
}

/// Parameters for reference use cases
class ReferenceParams extends Equatable {
  /// Reference information
  final Reference reference;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const ReferenceParams({
    required this.reference,
    this.candidateId,
  });

  @override
  List<Object?> get props => [reference, candidateId];
}

/// Parameters for delete reference use case
class DeleteReferenceParams extends Equatable {
  /// Reference ID
  final int referenceId;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const DeleteReferenceParams({
    required this.referenceId,
    this.candidateId,
  });

  @override
  List<Object?> get props => [referenceId, candidateId];
}