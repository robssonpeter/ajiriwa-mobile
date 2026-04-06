import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/resume_repository.dart';

/// Get rendered resume HTML use case
class GetResumeHtml implements UseCase<String, Params> {
  /// Repository
  final ResumeRepository repository;

  /// Constructor
  const GetResumeHtml(this.repository);

  @override
  Future<Either<Failure, String>> call(Params params) async {
    return await repository.getResumeHtml(candidateId: params.candidateId);
  }
}

/// Parameters for GetResumeHtml use case
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