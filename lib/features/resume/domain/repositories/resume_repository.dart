import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/entities.dart';

/// Repository interface for resume operations
abstract class ResumeRepository {
  /// Get resume section data
  /// 
  /// [section] is the section name (personal, career, experience, education, language, skills, awards, reference)
  /// [candidateId] is optional and used for multi-CV support
  Future<Either<Failure, ResumeSectionResponse>> getResumeSection(String section, {int? candidateId});

  /// Get complete resume data
  /// 
  /// [candidateId] is optional and used for multi-CV support
  Future<Either<Failure, ResumeData>> getResumeData({int? candidateId});

  /// Get rendered resume HTML
  /// 
  /// [candidateId] is optional and used for multi-CV support
  Future<Either<Failure, String>> getResumeHtml({int? candidateId});

  /// Update personal information
  Future<Either<Failure, bool>> updatePersonal(Personal personal, {int? candidateId});

  /// Update career information
  Future<Either<Failure, bool>> updateCareer(Career career, {int? candidateId});

  /// Add work experience
  Future<Either<Failure, bool>> addExperience(Experience experience, {int? candidateId});

  /// Update work experience
  Future<Either<Failure, bool>> updateExperience(Experience experience, {int? candidateId});

  /// Delete work experience
  Future<Either<Failure, bool>> deleteExperience(int experienceId, {int? candidateId});

  /// Add education
  Future<Either<Failure, bool>> addEducation(Education education, {int? candidateId});

  /// Update education
  Future<Either<Failure, bool>> updateEducation(Education education, {int? candidateId});

  /// Delete education
  Future<Either<Failure, bool>> deleteEducation(int educationId, {int? candidateId});

  /// Add language
  Future<Either<Failure, bool>> addLanguage(Language language, {int? candidateId});

  /// Update language
  Future<Either<Failure, bool>> updateLanguage(Language language, {int? candidateId});

  /// Delete language
  Future<Either<Failure, bool>> deleteLanguage(int languageId, {int? candidateId});

  /// Add skill
  Future<Either<Failure, bool>> addSkill(Skill skill, {int? candidateId});

  /// Update skill
  Future<Either<Failure, bool>> updateSkill(Skill skill, {int? candidateId});

  /// Delete skill
  Future<Either<Failure, bool>> deleteSkill(int skillId, {int? candidateId});

  /// Add award/certificate
  Future<Either<Failure, bool>> addAward(Award award, {int? candidateId});

  /// Update award/certificate
  Future<Either<Failure, bool>> updateAward(Award award, {int? candidateId});

  /// Delete award/certificate
  Future<Either<Failure, bool>> deleteAward(int awardId, {int? candidateId});

  /// Add reference
  Future<Either<Failure, bool>> addReference(Reference reference, {int? candidateId});

  /// Update reference
  Future<Either<Failure, bool>> updateReference(Reference reference, {int? candidateId});

  /// Delete reference
  Future<Either<Failure, bool>> deleteReference(int referenceId, {int? candidateId});
}
