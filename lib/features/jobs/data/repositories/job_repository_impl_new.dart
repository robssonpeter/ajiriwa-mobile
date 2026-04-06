import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/job_apply_context.dart';
import '../../domain/entities/job_apply_response.dart';
import '../../domain/entities/job_details.dart';
import '../../domain/entities/job_eligibility.dart';
import '../../domain/entities/job_screening.dart';
import '../../domain/entities/jobs_response.dart';
import '../../domain/repositories/job_repository.dart';
import '../datasources/job_data_source.dart';
import '../models/job_apply_request_model.dart';

/// Implementation of the JobRepository interface
class JobRepositoryImpl implements JobRepository {
  /// Remote data source
  final JobDataSource remoteDataSource;

  /// Network info
  final NetworkInfo networkInfo;

  /// Constructor
  JobRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, JobDetails>> getJobDetails(String slug) async {
    if (await networkInfo.isConnected) {
      try {
        final jobDetailsModel = await remoteDataSource.getJobDetails(slug);
        return Right(jobDetailsModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return const Left(ServerFailure('An unexpected error occurred'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, JobsResponse>> getJobs({
    String? query,
    String? location,
    String? jobType,
    int? category,
    int? industry,
    int? minSalary,
    int? maxSalary,
    int? page,
    int? perPage,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final jobsResponseModel = await remoteDataSource.getJobs(
          query: query,
          location: location,
          jobType: jobType,
          category: category,
          industry: industry,
          minSalary: minSalary,
          maxSalary: maxSalary,
          page: page,
          perPage: perPage,
        );
        return Right(jobsResponseModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return const Left(ServerFailure('An unexpected error occurred'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, JobEligibility>> checkJobEligibility(int jobId, {int? candidateId}) async {
    if (await networkInfo.isConnected) {
      try {
        final eligibilityModel = await remoteDataSource.checkJobEligibility(jobId, candidateId: candidateId);
        return Right(eligibilityModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('An unexpected error occurred'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, JobScreening>> getJobScreening(int jobId) async {
    if (await networkInfo.isConnected) {
      try {
        final screeningModel = await remoteDataSource.getJobScreening(jobId);
        return Right(screeningModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return const Left(ServerFailure('An unexpected error occurred'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, JobApplyResponse>> applyForJob({
    required int jobId,
    required List<Map<String, dynamic>> screeningAnswers,
    required int resumeId,
    String? coverLetter,
    List<Map<String, dynamic>>? attachments,
    int? candidateId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // Convert the screening answers to ScreeningAnswerModel objects
        final screeningAnswerModels = screeningAnswers.map((answer) {
          return ScreeningAnswerModel(
            questionId: answer['question_id'],
            answerText: answer['answer_text'],
            answerChoiceId: answer['answer_choice_id'],
            type: answer['type'],
          );
        }).toList();

        // Convert the attachments to AttachmentModel objects if provided
        final attachmentModels = attachments?.map((attachment) {
          return AttachmentModel(
            fileId: attachment['file_id'],
            type: attachment['type'],
          );
        }).toList();

        // Create the request model
        final requestModel = JobApplyRequestModel(
          screeningAnswers: screeningAnswerModels,
          resumeId: resumeId,
          coverLetter: coverLetter,
          attachments: attachmentModels,
        );

        // Call the data source
        final responseModel = await remoteDataSource.applyForJob(jobId, requestModel, candidateId: candidateId);
        return Right(responseModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return const Left(ServerFailure('An unexpected error occurred'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, JobApplyIntentResponse>> recordApplyIntent({
    required int jobId,
    required String mode,
    String? notes,
    int? candidateId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // Create the request model
        final requestModel = JobApplyIntentRequestModel(
          mode: mode,
          notes: notes,
        );

        // Call the data source
        final responseModel = await remoteDataSource.recordApplyIntent(jobId, requestModel, candidateId: candidateId);
        return Right(responseModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return const Left(ServerFailure('An unexpected error occurred'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> markExternalApplicationAsApplied(int applicationId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.markExternalApplicationAsApplied(applicationId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return const Left(ServerFailure('An unexpected error occurred'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> recordExternalClick(int jobId, {int? candidateId}) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.recordExternalClick(jobId, candidateId: candidateId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return const Left(ServerFailure('An unexpected error occurred'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, JobApplyContext>> getApplyContextBySlug(String slug, {int? candidateId}) async {
    if (await networkInfo.isConnected) {
      try {
        final applyContextModel = await remoteDataSource.getApplyContextBySlug(slug, candidateId: candidateId);
        return Right(applyContextModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return const Left(ServerFailure('An unexpected error occurred'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<JobDetails>>> getSavedJobs() async {
    if (await networkInfo.isConnected) {
      try {
        final savedJobsModels = await remoteDataSource.getSavedJobs();
        final savedJobs = savedJobsModels.map((model) => model.toEntity()).toList();
        return Right(savedJobs);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> saveJob(int jobId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.saveJob(jobId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> unsaveJob(int jobId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.unsaveJob(jobId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCandidates() async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getCandidates();
        return Right(response);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createCandidate(String professionalTitle) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.createCandidate(professionalTitle);
        return Right(response);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> generateCoverLetter({
    required int jobId,
    String? startingPoint,
    String? refineInstructions,
    int? candidateId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.generateCoverLetter(
          jobId: jobId,
          startingPoint: startingPoint,
          refineInstructions: refineInstructions,
          candidateId: candidateId,
        );
        return Right(response);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('An unexpected error occurred: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
