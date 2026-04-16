import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/job_alert.dart';
import '../../domain/repositories/job_alert_repository.dart';
import '../datasources/job_alert_data_source.dart';

class JobAlertRepositoryImpl implements JobAlertRepository {
  final JobAlertDataSource dataSource;
  final NetworkInfo networkInfo;

  JobAlertRepositoryImpl({required this.dataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<JobAlert>>> getAlerts() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final models = await dataSource.getAlerts();
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, JobAlert>> createAlert({
    required String name,
    String? keywords,
    String? location,
    int? jobTypeId,
    bool isRemote = false,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final model = await dataSource.createAlert(
        name: name,
        keywords: keywords,
        location: location,
        jobTypeId: jobTypeId,
        isRemote: isRemote,
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, JobAlert>> updateAlert({
    required int id,
    required String name,
    String? keywords,
    String? location,
    int? jobTypeId,
    bool isRemote = false,
    bool isActive = true,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      final model = await dataSource.updateAlert(
        id: id,
        name: name,
        keywords: keywords,
        location: location,
        jobTypeId: jobTypeId,
        isRemote: isRemote,
        isActive: isActive,
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAlert(int id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }
    try {
      await dataSource.deleteAlert(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(ServerFailure('An unexpected error occurred'));
    }
  }
}
