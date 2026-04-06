import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/applications_response.dart';
import '../../domain/entities/application_details.dart';
import '../../domain/repositories/application_repository.dart';
import '../datasources/application_data_source.dart';

/// Implementation of the ApplicationRepository interface
class ApplicationRepositoryImpl implements ApplicationRepository {
  /// Remote data source
  final ApplicationDataSource remoteDataSource;

  /// Network info
  final NetworkInfo networkInfo;

  /// Constructor
  ApplicationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ApplicationsResponse>> getApplications({
    int? page,
    int? perPage,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final applicationsResponseModel = await remoteDataSource.getApplications(
          page: page,
          perPage: perPage,
        );
        return Right(applicationsResponseModel.toEntity());
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
  Future<Either<Failure, ApplicationDetails>> getApplicationDetails(int applicationId) async {
    if (await networkInfo.isConnected) {
      try {
        final applicationDetailsModel = await remoteDataSource.getApplicationDetails(applicationId);
        return Right(applicationDetailsModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return const Left(ServerFailure('An unexpected error occurred'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
