import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/entities.dart';
import '../repositories/resume_repository.dart';

/// Add language use case
class AddLanguage implements UseCase<bool, LanguageParams> {
  /// Repository
  final ResumeRepository repository;

  /// Constructor
  const AddLanguage(this.repository);

  @override
  Future<Either<Failure, bool>> call(LanguageParams params) async {
    return await repository.addLanguage(params.language, candidateId: params.candidateId);
  }
}

/// Update language use case
class UpdateLanguage implements UseCase<bool, LanguageParams> {
  /// Repository
  final ResumeRepository repository;

  /// Constructor
  const UpdateLanguage(this.repository);

  @override
  Future<Either<Failure, bool>> call(LanguageParams params) async {
    return await repository.updateLanguage(params.language, candidateId: params.candidateId);
  }
}

/// Delete language use case
class DeleteLanguage implements UseCase<bool, DeleteLanguageParams> {
  /// Repository
  final ResumeRepository repository;

  /// Constructor
  const DeleteLanguage(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteLanguageParams params) async {
    return await repository.deleteLanguage(params.languageId, candidateId: params.candidateId);
  }
}

/// Parameters for language use cases
class LanguageParams extends Equatable {
  /// Language information
  final Language language;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const LanguageParams({
    required this.language,
    this.candidateId,
  });

  @override
  List<Object?> get props => [language, candidateId];
}

/// Parameters for delete language use case
class DeleteLanguageParams extends Equatable {
  /// Language ID
  final int languageId;

  /// Candidate ID (optional)
  final int? candidateId;

  /// Constructor
  const DeleteLanguageParams({
    required this.languageId,
    this.candidateId,
  });

  @override
  List<Object?> get props => [languageId, candidateId];
}