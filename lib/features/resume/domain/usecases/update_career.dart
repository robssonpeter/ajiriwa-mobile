import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/entities.dart';
import '../repositories/resume_repository.dart';

/// Update career information use case
class UpdateCareer implements UseCase<bool, Params> {
  /// Repository
  final ResumeRepository repository;

  /// Constructor
  const UpdateCareer(this.repository);

  @override
  Future<Either<Failure, bool>> call(Params params) async {
    return await repository.updateCareer(params.career, candidateId: params.candidateId);
  }
}

/// Parameters for UpdateCareer use case
class Params extends Equatable {
  /// Career information
  final Career career;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const Params({
    required this.career,
    this.candidateId,
  });

  @override
  List<Object?> get props => [career, candidateId];
}