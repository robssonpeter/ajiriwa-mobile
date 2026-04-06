import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/entities.dart';
import '../repositories/resume_repository.dart';

/// Update personal information use case
class UpdatePersonal implements UseCase<bool, Params> {
  /// Repository
  final ResumeRepository repository;

  /// Constructor
  const UpdatePersonal(this.repository);

  @override
  Future<Either<Failure, bool>> call(Params params) async {
    return await repository.updatePersonal(params.personal, candidateId: params.candidateId);
  }
}

/// Parameters for UpdatePersonal use case
class Params extends Equatable {
  /// Personal information
  final Personal personal;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const Params({
    required this.personal,
    this.candidateId,
  });

  @override
  List<Object?> get props => [personal, candidateId];
}