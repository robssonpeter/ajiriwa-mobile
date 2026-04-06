import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/entities.dart';
import '../repositories/resume_repository.dart';

/// Add award use case
class AddAward implements UseCase<bool, AwardParams> {
  /// Repository
  final ResumeRepository repository;

  /// Constructor
  const AddAward(this.repository);

  @override
  Future<Either<Failure, bool>> call(AwardParams params) async {
    return await repository.addAward(params.award, candidateId: params.candidateId);
  }
}

/// Update award use case
class UpdateAward implements UseCase<bool, AwardParams> {
  /// Repository
  final ResumeRepository repository;

  /// Constructor
  const UpdateAward(this.repository);

  @override
  Future<Either<Failure, bool>> call(AwardParams params) async {
    return await repository.updateAward(params.award, candidateId: params.candidateId);
  }
}

/// Delete award use case
class DeleteAward implements UseCase<bool, DeleteAwardParams> {
  /// Repository
  final ResumeRepository repository;

  /// Constructor
  const DeleteAward(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteAwardParams params) async {
    return await repository.deleteAward(params.awardId, candidateId: params.candidateId);
  }
}

/// Parameters for award use cases
class AwardParams extends Equatable {
  /// Award information
  final Award award;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const AwardParams({
    required this.award,
    this.candidateId,
  });

  @override
  List<Object?> get props => [award, candidateId];
}

/// Parameters for delete award use case
class DeleteAwardParams extends Equatable {
  /// Award ID
  final int awardId;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const DeleteAwardParams({
    required this.awardId,
    this.candidateId,
  });

  @override
  List<Object?> get props => [awardId, candidateId];
}