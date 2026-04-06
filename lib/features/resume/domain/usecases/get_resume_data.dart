import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/entities.dart';
import '../repositories/resume_repository.dart';

/// Get complete resume data use case
class GetResumeData implements UseCase<ResumeData, Params> {
  /// Repository
  final ResumeRepository repository;

  /// Constructor
  const GetResumeData(this.repository);

  @override
  Future<Either<Failure, ResumeData>> call(Params params) async {
    return await repository.getResumeData(candidateId: params.candidateId);
  }
}

/// Parameters for GetResumeData use case
class Params extends Equatable {
  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const Params({
    this.candidateId,
  });

  @override
  List<Object?> get props => [candidateId];
}