import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/resume_repository.dart';
import '../datasources/datasources.dart';
import '../models/models.dart';

/// Implementation of [ResumeRepository]
class ResumeRepositoryImpl implements ResumeRepository {
  /// Remote data source
  final ResumeRemoteDataSource remoteDataSource;

  /// Network info
  final NetworkInfo networkInfo;

  /// Constructor
  const ResumeRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ResumeSectionResponse>> getResumeSection(String section, {int? candidateId}) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getResumeSection(section, candidateId: candidateId);
        return Right(response);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, ResumeData>> getResumeData({int? candidateId}) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getResumeData(candidateId: candidateId);
        return Right(response);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, String>> getResumeHtml({int? candidateId}) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getResumeHtml(candidateId: candidateId);
        return Right(response);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> updatePersonal(Personal personal, {int? candidateId}) async {
    if (await networkInfo.isConnected) {
      try {
        final personalModel = PersonalModel(
          firstName: personal.firstName,
          lastName: personal.lastName,
          email: personal.email,
          phone: personal.phone,
          address: personal.address,
          city: personal.city,
          country: personal.country,
          postalCode: personal.postalCode,
          gender: personal.gender,
          dateOfBirth: personal.dateOfBirth,
          headline: personal.headline,
          summary: personal.summary,
          photoUrl: personal.photoUrl,
        );
        final result = await remoteDataSource.updatePersonal(personalModel, candidateId: candidateId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> updateCareer(Career career, {int? candidateId}) async {
    if (await networkInfo.isConnected) {
      try {
        final careerModel = CareerModel(
          jobTitle: career.jobTitle,
          industry: career.industry,
          industryId: career.industryId,
          yearsOfExperience: career.yearsOfExperience,
          careerLevel: career.careerLevel,
          salaryExpectation: career.salaryExpectation,
          careerObjective: career.careerObjective,
        );
        final result = await remoteDataSource.updateCareer(careerModel, candidateId: candidateId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> addExperience(Experience experience, {int? candidateId}) async {
    if (await networkInfo.isConnected) {
      try {
        final experienceModel = ExperienceModel(
          jobTitle: experience.jobTitle,
          company: experience.company,
          startDate: experience.startDate,
          endDate: experience.endDate,
          isCurrent: experience.isCurrent,
          description: experience.description,
          location: experience.location,
        );
        final result = await remoteDataSource.addExperience(experienceModel, candidateId: candidateId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> updateExperience(Experience experience, {int? candidateId}) async {
    if (await networkInfo.isConnected) {
      try {
        final experienceModel = ExperienceModel(
          id: experience.id,
          jobTitle: experience.jobTitle,
          company: experience.company,
          startDate: experience.startDate,
          endDate: experience.endDate,
          isCurrent: experience.isCurrent,
          description: experience.description,
          location: experience.location,
        );
        final result = await remoteDataSource.updateExperience(experienceModel, candidateId: candidateId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteExperience(int experienceId, {int? candidateId}) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.deleteExperience(experienceId, candidateId: candidateId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> addEducation(Education education, {int? candidateId}) async {
    if (await networkInfo.isConnected) {
      try {
        final educationModel = EducationModel(
          institution: education.institution,
          degree: education.degree,
          fieldOfStudy: education.fieldOfStudy,
          startDate: education.startDate,
          endDate: education.endDate,
          isCurrent: education.isCurrent,
          description: education.description,
          educationLevelId: education.educationLevelId,
          educationLevel: education.educationLevel,
          countryId: education.countryId,
        );
        final result = await remoteDataSource.addEducation(educationModel, candidateId: candidateId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> updateEducation(Education education, {int? candidateId}) async {
    if (await networkInfo.isConnected) {
      try {
        final educationModel = EducationModel(
          id: education.id,
          institution: education.institution,
          degree: education.degree,
          fieldOfStudy: education.fieldOfStudy,
          startDate: education.startDate,
          endDate: education.endDate,
          isCurrent: education.isCurrent,
          description: education.description,
          educationLevelId: education.educationLevelId,
          educationLevel: education.educationLevel,
          countryId: education.countryId,
        );
        final result = await remoteDataSource.updateEducation(educationModel, candidateId: candidateId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteEducation(int educationId, {int? candidateId}) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.deleteEducation(educationId, candidateId: candidateId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> addLanguage(Language language, {int? candidateId}) async {
    if (await networkInfo.isConnected) {
      try {
        final languageModel = LanguageModel(
          name: language.name,
          listening: language.listening,
          speaking: language.speaking,
          reading: language.reading,
          writing: language.writing,
          levelId: language.levelId,
          level: language.level,
        );
        final result = await remoteDataSource.addLanguage(languageModel, candidateId: candidateId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> updateLanguage(Language language, {int? candidateId}) async {
    if (await networkInfo.isConnected) {
      try {
        final languageModel = LanguageModel(
          id: language.id,
          name: language.name,
          listening: language.listening,
          speaking: language.speaking,
          reading: language.reading,
          writing: language.writing,
          levelId: language.levelId,
          level: language.level,
        );
        final result = await remoteDataSource.updateLanguage(languageModel, candidateId: candidateId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteLanguage(int languageId, {int? candidateId}) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.deleteLanguage(languageId, candidateId: candidateId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> addSkill(Skill skill, {int? candidateId}) async {
    if (await networkInfo.isConnected) {
      try {
        final skillModel = SkillModel(
          name: skill.name,
          levelId: skill.levelId,
          level: skill.level,
        );
        final result = await remoteDataSource.addSkill(skillModel, candidateId: candidateId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> updateSkill(Skill skill, {int? candidateId}) async {
    if (await networkInfo.isConnected) {
      try {
        final skillModel = SkillModel(
          id: skill.id,
          name: skill.name,
          levelId: skill.levelId,
          level: skill.level,
        );
        final result = await remoteDataSource.updateSkill(skillModel, candidateId: candidateId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteSkill(int skillId, {int? candidateId}) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.deleteSkill(skillId, candidateId: candidateId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> addAward(Award award, {int? candidateId}) async {
    if (await networkInfo.isConnected) {
      try {
        final awardModel = AwardModel(
          name: award.name,
          issuer: award.issuer,
          date: award.date,
          description: award.description,
          categoryId: award.categoryId,
          category: award.category,
        );
        final result = await remoteDataSource.addAward(awardModel, candidateId: candidateId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> updateAward(Award award, {int? candidateId}) async {
    if (await networkInfo.isConnected) {
      try {
        final awardModel = AwardModel(
          id: award.id,
          name: award.name,
          issuer: award.issuer,
          date: award.date,
          description: award.description,
          categoryId: award.categoryId,
          category: award.category,
        );
        final result = await remoteDataSource.updateAward(awardModel, candidateId: candidateId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAward(int awardId, {int? candidateId}) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.deleteAward(awardId, candidateId: candidateId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> addReference(Reference reference, {int? candidateId}) async {
    if (await networkInfo.isConnected) {
      try {
        final referenceModel = ReferenceModel(
          name: reference.name,
          position: reference.position,
          company: reference.company,
          email: reference.email,
          phone: reference.phone,
          relationship: reference.relationship,
        );
        final result = await remoteDataSource.addReference(referenceModel, candidateId: candidateId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> updateReference(Reference reference, {int? candidateId}) async {
    if (await networkInfo.isConnected) {
      try {
        final referenceModel = ReferenceModel(
          id: reference.id,
          name: reference.name,
          position: reference.position,
          company: reference.company,
          email: reference.email,
          phone: reference.phone,
          relationship: reference.relationship,
        );
        final result = await remoteDataSource.updateReference(referenceModel, candidateId: candidateId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteReference(int referenceId, {int? candidateId}) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.deleteReference(referenceId, candidateId: candidateId);
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
