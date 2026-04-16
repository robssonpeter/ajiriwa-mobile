import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_data_source.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingDataSource dataSource;

  OnboardingRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> uploadCv(File file, int candidateId) async {
    try {
      final result = await dataSource.uploadCv(file, candidateId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> parseCv({
    required String fileUrl,
    required int candidateId,
    int? mediaId,
  }) async {
    try {
      final result = await dataSource.parseCv(
        fileUrl: fileUrl,
        candidateId: candidateId,
        mediaId: mediaId,
      );
      final completion = result['profile_completion'] as int? ?? 0;
      return Right(completion);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
