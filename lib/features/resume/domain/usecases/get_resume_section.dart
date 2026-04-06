import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/entities.dart';
import '../repositories/resume_repository.dart';

/// Get resume section use case
class GetResumeSection implements UseCase<ResumeSectionResponse, Params> {
  /// Repository
  final ResumeRepository repository;

  /// Constructor
  const GetResumeSection(this.repository);

  @override
  Future<Either<Failure, ResumeSectionResponse>> call(Params params) async {
    return await repository.getResumeSection(params.section, candidateId: params.candidateId);
  }
}

/// Parameters for GetResumeSection use case
class Params extends Equatable {
  /// Section name
  final String section;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const Params({
    required this.section,
    this.candidateId,
  });

  @override
  List<Object?> get props => [section, candidateId];
}